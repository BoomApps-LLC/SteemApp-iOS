//
//  CurrentMedianPrice.swift
//  Platform
//
//  Created by Siarhei Suliukou on 5/17/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

struct CurrentMedianPriceRaw: Codable {
    let base: String
    let quote: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.base = try container.decode(String.self, forKey: .base)
        self.quote = try container.decode(String.self, forKey: .quote)
    }
}

extension CurrentMedianPriceRaw: EntityConvertable {
    typealias EntityType = CurrentMedianPrice
    
    var asEntity: CurrentMedianPrice {
        return CurrentMedianPrice(base: self.base.double, quote: self.quote.double)
    }
}


