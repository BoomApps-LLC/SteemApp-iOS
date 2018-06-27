//
//  CoinmarketcapRaw.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/22/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

struct CoinmarketcapsRaw: Codable {
    let items: [CoinmarketcapRaw]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self.items = try container.decode([CoinmarketcapRaw].self)
    }
}

struct CoinmarketcapRaw: Codable {
    let id: String
    let name: String
    let symbol: String
    let price_usd: String
    let market_cap_usd: String
    let available_supply: String
    let total_supply: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case price_usd
        case market_cap_usd
        case available_supply
        case total_supply
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.price_usd = try container.decode(String.self, forKey: .price_usd)
        self.market_cap_usd = try container.decode(String.self, forKey: .market_cap_usd)
        self.available_supply = try container.decode(String.self, forKey: .available_supply)
        self.total_supply = try container.decode(String.self, forKey: .total_supply)
    }
}
