//
//  WalletAPI.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/21/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum WalletAPI {
    case helloacm(endpointURL: URL)
    case coinmarketcapSBD2USD(endpointURL: URL)
    case coinmarketcapSTEEM2USD(endpointURL: URL)
}

extension WalletAPI: Moya.TargetType {
    var path: String {
        switch self {
        case .helloacm, .coinmarketcapSBD2USD, .coinmarketcapSTEEM2USD:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .helloacm, .coinmarketcapSBD2USD, .coinmarketcapSTEEM2USD:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Moya.Task {
        switch self {
        case .helloacm, .coinmarketcapSBD2USD, .coinmarketcapSTEEM2USD:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        switch self {
        case .helloacm(let url), .coinmarketcapSBD2USD(let url), .coinmarketcapSTEEM2USD(let url):
            return url
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .helloacm, .coinmarketcapSBD2USD, .coinmarketcapSTEEM2USD:
            return [:]
        }
    }
    
    var validate: Bool {
        return false
    }
}

extension WalletAPI: Validatable {
    var validations: [DataRequest.Validation] {
        return [ValidStatusCodes.standart]
    }
}

extension WalletAPI: Serializable {
    var serializer: Parseble {
        switch self {
        default:
            return JSONDataSerializer()
        }
    }
}

