import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroKitMacros
import MacroTesting


// edges cases:
//  - overloaded functions

final class MockWorkerMacroTests: XCTestCase {
    override func invokeTest() {
      withMacroTesting(macros: [MockWorkerMacro.self]) {
        super.invokeTest()
      }
    }

    func testPlaygroundReverseEngineering() {
        assertMacro(
//            record: true,
            of: {
            """
                @MockWorker
                public protocol KYCWorkerProtocol: AnyObject {
                    typealias KYCALIAS = (Result<String, Error>) -> Void

                    func sendKYC(model: Bool, completion: @escaping KYCALIAS)
                    func fetchKolasRecipientInfo(
                        with model: Int,
                        completion: @escaping (Result<Int, ServiceError>) -> Void
                    )
                }
            """
            }
        ) {
            """
                
                public protocol KYCWorkerProtocol: AnyObject {
                    typealias KYCALIAS = (Result<String, Error>) -> Void

                    func sendKYC(model: Bool, completion: @escaping KYCALIAS)
                    func fetchKolasRecipientInfo(
                        with model: Int,
                        completion: @escaping (Result<Int, ServiceError>) -> Void
                    )
                }

            #if DEBUG

            public class KYCWorkerProtocolMock: KYCWorkerProtocol {
                enum Invocation: Equatable {
                    case sendKYC
                    case fetchKolasRecipientInfo
                }
                private (set) var invocations: [Invocation] = []
                public init() {
                }
                public var sendKYCResult: Result<String, Error> = .failure(.fake)
                public var fetchKolasRecipientInfoResult: Result<Int, ServiceError> = .failure(.fake)
                public func sendKYC(model: Bool, completion: @escaping KYCALIAS) {
                    invocations.append(.sendKYC)
                    completion(sendKYCResult)
                }
                public func fetchKolasRecipientInfo(
                            with model: Int,
                            completion: @escaping (Result<Int, ServiceError>) -> Void
                        ) {
                    invocations.append(.fetchKolasRecipientInfo)
                    completion(fetchKolasRecipientInfoResult)
                }
            }

            #endif
            """
        }
    }
}
