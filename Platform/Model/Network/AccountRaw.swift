//
//  UserRaw.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

struct AccountsRaw: Codable {
    let accounts: [AccountRaw]
}

struct AccountRaw: Codable {
    let id: Int64
    let name: String
    let reputation: String
    let json_metadata: String
    let sbd_balance: String
    let savings_sbd_balance: String
    let balance: String
    let savings_balance: String
    let vesting_shares: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int64.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        
        if let reputation = try? container.decode(Int64.self, forKey: CodingKeys.reputation) {
            self.reputation = "\(reputation)"
        } else if let reputation = try? container.decode(String.self, forKey: CodingKeys.reputation) {
            self.reputation = reputation
        } else {
            self.reputation = "0"
        }
        
        self.json_metadata = try container.decode(String.self, forKey: .json_metadata)
        self.sbd_balance = try container.decode(String.self, forKey: .sbd_balance)
        self.savings_sbd_balance = try container.decode(String.self, forKey: .savings_sbd_balance)
        self.balance = try container.decode(String.self, forKey: .balance)
        self.savings_balance = try container.decode(String.self, forKey: .savings_balance)
        self.vesting_shares = try container.decode(String.self, forKey: .vesting_shares)
    }
}

extension AccountRaw: EntityConvertable {
    typealias EntityType = Account
    
    var asEntity: Account {
        let r = Double(reputation) ?? 0.0
        let rep = floor((log10(r) - 9.0) * 9.0 + 25.0)
        
        return Account(id: id, name: name, json_metadata: json_metadata, reputation: rep, sbd_balance: sbd_balance.double,
                       savings_sbd_balance: savings_sbd_balance.double, balance: balance.double,
                       savings_balance: savings_balance.double, vesting_shares: vesting_shares.double)
    }
    
}

extension String {
    public var double: Double {
        return self.components(separatedBy: CharacterSet.whitespaces).compactMap({ Double($0) }).first ?? 0.0
    }
}
