public struct MockWorkerMacro: PeerMacro {
    enum Error: String, Swift.Error, DiagnosticMessage {
        var diagnosticID: MessageID { .init(domain: "MockWorkerMacro", id: rawValue) }
        var severity: DiagnosticSeverity { .error }
        var message: String {
            switch self {
            case .notAProtocol: return "@MockWorkerMacro can only be applied to protocols"
            case .noCompletionHandler: return "No 'completion' handler is found in one of the function"
            }
        }

        case notAProtocol
        case noCompletionHandler
    }

    public static func expansion<Context: MacroExpansionContext, Declaration: DeclSyntaxProtocol>(
        of node: AttributeSyntax,
        providingPeersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        guard let protoDecl = declaration.as(ProtocolDeclSyntax.self) else { throw Error.notAProtocol }

        let completionHandlers = try protoDecl.functions
            .compactMap { each -> DeclSyntax? in
                guard
                    let completionHandler = each.parameters.first(where: { param in
                    param.firstName.text == "completion"
                }),
                    let attributedType = AttributedTypeSyntax(completionHandler.type)
                else { 
                    throw Error.noCompletionHandler
                }

                if let identifierTypeSyntax = IdentifierTypeSyntax(attributedType.baseType) {
                    // If completion handler uses typealias, get name and find type from typealiases.
                    guard
                        let first = protoDecl.typealiases.first(where: { $0.name.text == identifierTypeSyntax.name.text }),
                        let functionTypeSyntax = FunctionTypeSyntax(first.initializer.value)
                    else {
                        return nil
                    }
                    return DeclSyntax(
                        "public var \(raw: each.name.text)Result: \(raw: functionTypeSyntax.parameters.description) = .failure(.fake)"
                    )
                } else if let functionTypeSyntax = FunctionTypeSyntax(attributedType.baseType) {
                    return DeclSyntax(
                        "public var \(raw: each.name.text)Result: \(raw: functionTypeSyntax.parameters.description) = .failure(.fake)"
                    )
                }
                return nil
            }
            .compactMap { MemberBlockItemSyntax(decl: $0) }

        let functions = protoDecl.functions
            .map(\.mockFunctionTest)
            .compactMap { MemberBlockItemSyntax(decl: $0) }

        let cls = ClassDeclSyntax(
            modifiers: DeclModifierListSyntax {
                DeclModifierSyntax(name: "public")
            },
            name: "\(raw: protoDecl.name.text)Mock",
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: TypeSyntax("\(raw: protoDecl.name.text)"))
            },
            genericWhereClause: nil,
            memberBlockBuilder: {
                EnumDeclSyntax(
                    name: "Invocation",
                    inheritanceClause: InheritanceClauseSyntax {
                        InheritedTypeSyntax(type: TypeSyntax("Equatable"))
                    }
                ) {
                    for function in protoDecl.functions {
                        EnumCaseDeclSyntax {
                            EnumCaseElementSyntax(
                                name: "\(raw: function.name.text)"
                            )
                        }
                    }
                }
                DeclSyntax("private(set) var invocations: [Invocation] = []")
                DeclSyntax("public init() {}")
                MemberBlockItemListSyntax(completionHandlers)
                MemberBlockItemListSyntax(functions)
            }
        )

        return [
            "#if DEBUG",
            DeclSyntax(cls),
            "#endif",
        ]
    }
}

extension FunctionDeclSyntax {
    fileprivate var mockFunctionTest: FunctionDeclSyntax {
        var newFunction = trimmed
        newFunction.accessLevel = .public
        newFunction.body = CodeBlockSyntax {
            DeclSyntax(
                "\n        invocations.append(.\(raw: name.text))\n        completion(\(raw: name.text)Result)"
            )
        }
        return newFunction
    }
}
