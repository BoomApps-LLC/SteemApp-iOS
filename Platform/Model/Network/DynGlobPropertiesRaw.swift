//
//  DynGlobPropertiesRaw.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation


struct DynGlobPropertiesRaw: Codable {
    let head_block_number: Int64
    let head_block_id: String
    let time: Date
    let last_irreversible_block_num: Int64
    let total_vesting_fund_steem: String
    let total_vesting_shares: String
    
    enum CodingKeys: String, CodingKey  {
        case head_block_number = "head_block_number"
        case head_block_id = "head_block_id"
        case time = "time"
        case last_irreversible_block_num = "last_irreversible_block_num"
        case total_vesting_fund_steem = "total_vesting_fund_steem"
        case total_vesting_shares = "total_vesting_shares"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.head_block_number = try container.decode(Int64.self, forKey: .head_block_number)
        self.head_block_id = try container.decode(String.self, forKey: .head_block_id)
        self.time = try container.decode(Date.self, forKey: .time)
        self.last_irreversible_block_num = try container.decode(Int64.self, forKey: .last_irreversible_block_num)
        self.total_vesting_fund_steem = try container.decode(String.self, forKey: .total_vesting_fund_steem)
        self.total_vesting_shares = try container.decode(String.self, forKey: .total_vesting_shares)
        
    }
}

extension DynGlobPropertiesRaw: EntityConvertable {
    typealias EntityType = DynGlobProperties
    
    var asEntity: DynGlobProperties {
        return DynGlobProperties(head_block_number: head_block_number,
                                 head_block_id: head_block_id,
                                 time: time,
                                 last_irreversible_block_num: last_irreversible_block_num)
    }
}
