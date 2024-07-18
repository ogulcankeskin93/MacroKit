import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroKitMacros
import MacroTesting

// edges cases:
//  - overloaded functions

final class FakeMacroTests: XCTestCase {
    override func invokeTest() {
        withMacroTesting(macros: [FakeMacro.self]) {
            super.invokeTest()
        }
    }

    func test_FakeExtension() {
        assertMacro(
//            record: true,
            of: {
                """
                @Fake
                public struct User {
                    public var id: Int?
                    public var name: String
                    @Codec public var name: Test
                    @Codec public var optional: Test?
                }
                """
            }
        ) {
            """
            public struct User {
                public var id: Int?
                public var name: String
                @Codec public var name: Test
                @Codec public var optional: Test?

                public static func fake(
                    id: Int? = nil,
                    name: String,
                    name: Test,
                    optional: Test? = nil
                ) -> Self {
                    Self (
                        id: id,
                        name: name,
                        name: Codec<Test>(wrappedValue: name),
                        optional: Codec<Test?>(wrappedValue: optional)
                    )
                }
            }
            """
        }
    }
}
