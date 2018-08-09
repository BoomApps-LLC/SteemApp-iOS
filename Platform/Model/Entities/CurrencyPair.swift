//
//  CurrencyPair.swift
//  Platform
//
//  Created by Siarhei Suliukou on 8/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public enum Currency: String {
    case steem
    case sbd
    case bts
    case btc
    case eth
    case bitusd
    
    public var sortIdx: Int {
        switch self {
        case .steem:
            return 0
        case .sbd:
            return 1
        case .bts:
            return 2
        case .btc:
            return 3
        case .eth:
            return 4
        case .bitusd:
            return 5
        }
    }
    
    public var lbl: String {
        switch self {
        case .steem:
            return "STEEM"
        case .sbd:
            return "SBD"
        case .bts:
            return "BTS"
        case .btc:
            return "BTC"
        case .eth:
            return "ETH"
        case .bitusd:
            return "$"
        }
    }
}

public struct CurrencyPair {
    public let inputAmount: String
    public let inputCoinType: String
    public let outputAmount: String
    public let outputCoinType: String
    
    public init(inputAmount: String, inputCoinType: String, outputAmount: String, outputCoinType: String) {
        self.inputAmount = inputAmount
        self.inputCoinType = inputCoinType
        self.outputAmount = outputAmount
        self.outputCoinType = outputCoinType
    }
}

extension CurrencyPairRaw: EntityConvertable {
    typealias EntityType = CurrencyPair
    
    var asEntity: CurrencyPair {
        return CurrencyPair(inputAmount: inputAmount,
                            inputCoinType: inputCoinType,
                            outputAmount: outputAmount,
                            outputCoinType: outputCoinType)
    }
    
}
