//
//  UserAPI.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Moya
import Alamofire

// Targets -> Endpoints -> Requests

enum UserAPI {
    case login(endpointURL: URL, userName: String, password: String)
    case getBlock(endpointURL: URL, block: Int64)
    case getAccounts(endpointURL: URL, accounts: [String])
    case getDynamicGlobalProperties(endpointURL: URL)
}

extension UserAPI: Moya.TargetType {
    var path: String {
        switch self {
        case .login, .getBlock, .getDynamicGlobalProperties, .getAccounts:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .getBlock, .getDynamicGlobalProperties, .getAccounts:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Moya.Task {
        switch self {
        case .login, .getBlock, .getDynamicGlobalProperties, .getAccounts:
            return .requestData(body.utf8Encoded)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        switch self {
        case .login(let url, _, _):
            return url
        case .getBlock(endpointURL: let url, block: _):
            return url
        case .getDynamicGlobalProperties(endpointURL: let url):
            return url
        case .getAccounts(let url, _):
            return url
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .login, .getBlock, .getDynamicGlobalProperties, .getAccounts:
            return [:]
        }
    }
    
    var validate: Bool {
        return false
    }
}

extension UserAPI: RPCConvertable {
    var body: String {
        switch self {
        case .login(endpointURL: _, userName: let username, password: let password):
            return "\(username) \(password)"
        case .getBlock(_, let block):
            return DatabaseRPCApi.get_block([block]).represent
        case .getDynamicGlobalProperties:
            return DatabaseRPCApi.get_dynamic_global_properties.represent
        case .getAccounts(_, accounts: let accounts):
            return DatabaseRPCApi.get_accounts(accounts).represent
        }
    }
}

extension UserAPI: Validatable {
    var validations: [DataRequest.Validation] {
        return [ValidStatusCodes.standart]
    }
}

extension UserAPI: Serializable {
    var serializer: Parseble {
        switch self {
        default:
            return JSONBoxSerializer()
        }
    }
}
