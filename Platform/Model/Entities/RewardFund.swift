//
//  RewardFund.swift
//  Platform
//
//  Created by Siarhei Suliukou on 5/17/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public struct RewardFund: Codable {
    public let name: String
    public let reward_balance: Double
    public let recent_claims: Double
}
