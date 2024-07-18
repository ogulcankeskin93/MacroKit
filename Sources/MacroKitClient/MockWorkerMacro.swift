import Foundation
import MacroKit

@MockWorker
public protocol KYCWorkerProtocol: AnyObject {
    typealias PaymentRequestCompletionHandler = (Result<String, ServiceError>) -> Void
    typealias PaymentRequestDetailCompletionHandler = (Result<Bool, ServiceError>) -> Void
    typealias RejectPaymentCompletionHandler = (Result<Bool, ServiceError>) -> Void
    typealias ApprovePaymentCompletionHandler = (Result<Int, ServiceError>) -> Void
    typealias PaymentRequestCancelCompletionHandler = (Result<Int, ServiceError>) -> Void

    func fetchKolasRecipientInfo(
        with model: Int,
        completion: @escaping (Result<Int, ServiceError>) -> Void
    )
    func fetchKolasTypes(
        completion: @escaping (Result<[Int], ServiceError>) -> Void
    )
    func fetchReceiverInfo(
        with model: Int,
        completion: @escaping (Result<Int, ServiceError>) -> Void
    )
    func fetchPendings(
        completion: @escaping (Result<Int, ServiceError>) -> Void
    )
    func fetchQuickContacts(
        with currencyEnum: String,
        completion: @escaping (Result<[Int], ServiceError>) -> Void
    )
    func deleteQuickContactKolas(
        with model: Int,
        completion: @escaping (Result<Int, ServiceError>) -> Void
    )
    func deleteQuickContactIban(
        with iban: String,
        completion: @escaping (Result<Int, ServiceError>) -> Void
    )
    func fetchPaymentRequestPreview(
        with model: Int,
        completion: @escaping (Result<Int, ServiceError>) -> Void
    )
    func paymentRequestCreate(with model: Int, completion: @escaping (Result<Int, ServiceError>) -> Void)

    func fetchPaymentRequest(requestModel: Int, completion: @escaping PaymentRequestCompletionHandler)

    func fetchPaymentDetailRequest(referenceNo: String, completion: @escaping PaymentRequestDetailCompletionHandler)

    func rejectPayment(requestModel: Int, completion: @escaping RejectPaymentCompletionHandler)

    func approvePayment(requestModel: Int, completion: @escaping ApprovePaymentCompletionHandler)

    func paymentRequestCancel(with referenceNo: String, completion: @escaping PaymentRequestCancelCompletionHandler)
}

public struct ServiceError: Error {
    static var fake = ServiceError()
}

private let sut = KYCWorkerProtocolMock()
