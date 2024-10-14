//
//  DatabaseManager.swift
//  PayairSDK
//
//  Created by BNCH SOFTWARE on 14/10/2024.
//

import Combine

protocol DatabaseManager {
    func addNewTransaction(_ newTransaction: Transaction, contextCompleted: @escaping () -> Void)
    func getAllTransactions(for cardId: String) -> AnyPublisher<[Transaction], DatabaseError>
    func tagTransactionsAsProcessed(_ transactions: [Transaction])
}

final class LocalDatabaseManagerImp: DatabaseManager {

    // MARK: Private properties
    
    private var mockedData: [Transaction] = [
        Transaction(transactionId: "001", amount: Decimal(5.01), currencyCode: "USD", timestamp: "2024-09-12T12:30:00Z", cardUUID: "123", isProcessed: true),
        Transaction(transactionId: "002", amount: Decimal(25.03), currencyCode: "USD", timestamp: "2024-09-12T14:33:00Z", cardUUID: "124", isProcessed: true),
        Transaction(transactionId: "003", amount: Decimal(38.53), currencyCode: "USD", timestamp: "2024-09-12T17:10:00Z", cardUUID: "124", isProcessed: true),
        Transaction(transactionId: "004", amount: Decimal(42.13), currencyCode: "USD", timestamp: "2024-09-12T21:45:00Z", cardUUID: "124", isProcessed: false)
    ]
    
    // MARK: DatabaseManager protocol
    
    func addNewTransaction(_ newTransaction: Transaction, contextCompleted: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.mockedData.append(newTransaction)
            DispatchQueue.main.async {
                contextCompleted()
            }
        }
    }

    func getAllTransactions(for cardUUID: String) -> AnyPublisher<[Transaction], DatabaseError> {
        Future { [weak self] promise in
            guard let self = self else {
                return promise(.failure(.notIdentified))
            }
            promise(.success(
                self.mockedData.filter { $0.cardUUID == cardUUID}
            ))
        }
        .eraseToAnyPublisher()
    }

    /*
     For Firestore db with multiple entities to be more memory efficient
     there are more sophisticated methods to update data f.e by using batch()
    */
    func tagTransactionsAsProcessed(_ transactions: [Transaction]) {
        for index in mockedData.indices {
            if transactions.contains(where: { $0.transactionId == mockedData[index].transactionId }) {
                mockedData[index].isProcessed = true
            }
        }
    }
}
