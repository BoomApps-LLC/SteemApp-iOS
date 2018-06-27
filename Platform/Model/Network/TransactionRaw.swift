//
//  TransactionRaw.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/6/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

struct TransactionRaw: Codable {
    let ref_block_num: Int64
    let ref_block_prefix: Int64
    let expiration: Date
    
    enum CodingKeys: String, CodingKey  {
        case ref_block_num
        case ref_block_prefix
        case expiration
    }
}

extension TransactionRaw: EntityConvertable {
    typealias EntityType = Transaction
    
    var asEntity: Transaction {
        return Transaction(ref_block_num: ref_block_num,
                           ref_block_prefix: ref_block_prefix,
                           expiration: expiration)
    }
}
