public struct FakeMacro: MemberMacro {
    public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
        of node: AttributeSyntax,
        providingMembersOf declaration: Declaration,
        in context: Context
    ) throws -> [DeclSyntax] {
        let properties = declaration.properties.filter { $0.accessLevel >= declaration.declAccessLevel }
        guard !properties.isEmpty else { return [] }

        let fake: DeclSyntax = """
        \npublic static func fake(
        \(
        raw: properties.map { each in
            let type = each.type!.type.trimmed
            let isOptional = type.description.last == "?"
            return "\(each.identifier.text): \(type)\(isOptional ? " = nil" : "")"
        }.joined(separator: ",\n"))
        ) -> Self {
        Self(
        \(
        raw: properties.map { each in
            let type = each.type!.type.trimmed
            let isCodec = each.attributes.description.lowercased().contains("codec")
            return "\(each.identifier.text): \(isCodec ? "Codec<\(type)>(wrappedValue: \(each.identifier.text))" :  each.identifier.text)"
        }.joined(separator: ",\n"))
        )
        }
        """
        return [fake]
    }
}
