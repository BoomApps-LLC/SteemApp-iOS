//
//  BlockRaw.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

struct BlockRaw: Codable {
    let previous: String
    let timestamp: Date
    let witness: String
    let transaction_merkle_root: String
    let witness_signature: String
    let transactions: [TransactionRaw]
}

extension BlockRaw: EntityConvertable {
    typealias EntityType = Block
    
    var asEntity: Block {
        return Block(previous: previous, timestamp: timestamp, witness: witness, transaction_merkle_root: transaction_merkle_root, witness_signature: witness_signature, transactions: transactions.compactMap({$0.asEntity}))
    }
}
