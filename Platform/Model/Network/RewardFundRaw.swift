//
//  RewardFundRaw.swift
//  Platform
//
//  Created by Siarhei Suliukou on 5/17/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation


struct RewardFundRaw: Codable {
    let name: String
    let reward_balance: String
    let recent_claims: String
//    let last_update: "2018-05-17T06:48:27",
//    let content_constant: "2000000000000",
//    let percent_curation_rewards: 2500,
//    let percent_content_rewards: 10000,
//    let author_reward_curve: "linear",
//    let curation_reward_curve: "square_root"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.reward_balance = try container.decode(String.self, forKey: .reward_balance)
        self.recent_claims = try container.decode(String.self, forKey: .recent_claims)
    }
}

extension RewardFundRaw: EntityConvertable {
    typealias EntityType = RewardFund
    
    var asEntity: RewardFund {
        return RewardFund(name: self.name,
                          reward_balance: self.reward_balance.double,
                          recent_claims: self.recent_claims.double)
    }
}
