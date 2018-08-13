//
//  CurrencyPairRaw.swift
//  Platform
//
//  Created by Siarhei Suliukou on 8/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation


struct CurrencyPairRaw: Codable {
    let inputAmount: String
    let inputCoinType: String
    let outputAmount: String
    let outputCoinType: String
}
