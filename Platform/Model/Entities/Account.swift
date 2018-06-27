//
//  User.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

private struct JsonMetadata: Decodable {
    let profile_image: String?
    
    enum CodingKeys: String, CodingKey {
        case profile
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let profile = try container.decodeIfPresent([String: String].self, forKey: CodingKeys.profile)
        
        self.profile_image = profile?["profile_image"]
    }
}

public struct Account {
    public let id: Int64
    public let name: String
    public let json_metadata: String
    public let reputation: Double
    public var profile_image: String? {
        guard let data = self.json_metadata.data(using: .utf8) else { return nil }
        
        let jsonDecoder = JSONDecoder()
        let jsonMetadata = try? jsonDecoder.decode(JsonMetadata.self, from: data)
        
        return jsonMetadata?.profile_image
    }
    
    public let sbd_balance: Double
    public let savings_sbd_balance: Double
    public let balance: Double
    public let savings_balance: Double
    public let vesting_shares: Double
    
}
