//
//  TransactionService.swift
//  PayairSDK
//
//  Created by BNCH SOFTWARE on 14/10/2024.
//

import Combine

public final class TransactionService {
    
    // MARK: Public properties

    public var nonProcessedTransactionPublisher: AnyPublisher<[Transaction], Error> {
        get {
            return nonProcessedTransactionSubject.eraseToAnyPublisher()
        }
    }
    
    // MARK: Private properties

    private var database: DatabaseManager
    private var nonProcessedTransactionSubject = PassthroughSubject<[Transaction], Error>()
    private var cancelableBag = Set<AnyCancellable>()

    // MARK: Init

    init(
        database: DatabaseManager = LocalDatabaseManagerImp()
    ) {
        self.database = database
    }
    
    // MARK: Public functions

    ///  Fetch all not yet processed transactions for given card ID
    ///
    /// - Parameters:
    ///   - cardUUID: Id of the transaction's card
    ///
    ///   Finished with an updated data stream that the app must subscribe to observe the changes.
    public func fetchAllNonProcessedTransactions(for cardUUID: String) {
        database.getAllTransactions(for: cardUUID)
            .receive(on: DispatchQueue.main)
            .map { $0.filter { $0.isProcessed == false }}
            .sink { completion in
                /// In case data stream finished or failured, here we can propagate proper subjects to the higher layers of framework.
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    break
                }
            } receiveValue: { [weak self] nonProcessedTransactions in
                self?.database.tagTransactionsAsProcessed(nonProcessedTransactions)
                self?.nonProcessedTransactionSubject.send(nonProcessedTransactions)
            }
            .store(in: &cancelableBag)
    }
    
    /*
     The function represents the begginng of the current SDK flow. App, after getting Firebase notification,
     sends cardUUID to SDK. Afterwards the SDK updates the database. Although I don't have information on
     how the transaction is being made, for the purpose of the API it will be mocked.
    */
    public func addNewTransaction(contextCompleted: @escaping () -> Void) {
        let newTransaction = Transaction(transactionId: "005", amount: Decimal(2.99), currencyCode: "USD", timestamp: "2024-09-13T12:30:00Z", cardUUID: "124", isProcessed: false)
        
        /*
         Code in swift is executed in sequentional pattern which with our current database as array of
         transactions we don't need to worry about data integrity or race conditions.
         That being said, function has 'contextCompleted' closure to make sure we first do write
         operation and only then, the second read operation.
        */
        database.addNewTransaction(newTransaction, contextCompleted: contextCompleted)
    }
}
