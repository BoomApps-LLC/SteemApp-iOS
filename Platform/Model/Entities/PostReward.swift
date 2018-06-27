//
//  PostReward.swift
//  Platform
//
//  Created by Siarhei Suliukou on 5/20/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public struct PostReward: Codable {
    public let reward_balance: Double
    public let recent_claims: Double
    public let base: Double
}
