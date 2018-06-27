//
//  Block.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public struct Block {
    public let previous: String
    public let timestamp: Date
    public let witness: String
    public let transaction_merkle_root: String
    public let witness_signature: String
    public let transactions: [Transaction]
}

