//
//  Transaction.swift
//  PayairSDK
//
//  Created by BNCH SOFTWARE on 14/10/2024.
//

import Foundation

/// Transaction model
///
/// - Parameters:
///   - transactionId: A unique identifier for the transaction.
///   - amount: The amount of the transaction.
///   - currencyCode: ISO currency code
///   - timestamp: The date and time when the transaction occurred.
///   - cardUUID: The unique identified of the card 
///   - isProcessed: An information whether the transaction was already processed by the application
public struct Transaction: Codable {
    var transactionId: String
    var amount: Decimal
    var currencyCode: String
    var timestamp: String
    var cardUUID: String
    var isProcessed: Bool
}
