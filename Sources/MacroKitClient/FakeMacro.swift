import Foundation
import MacroKit

@Fake
public struct User {
    public var id: Int?
    public var name: String?
}

private let sut = User.fake()
