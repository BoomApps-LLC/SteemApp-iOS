//
//  DatabaseRPCApi.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/2/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

enum DatabaseRPCApi {
    case get_block([Int64])
    case get_dynamic_global_properties
    case get_accounts([String])
    case get_discussions_by_blog([String: Any?])
    case get_discussions_by_feed([String: Any?])
    case get_discussions_by_trending([String: Any?])
    case get_discussions_by_created([String: Any?])
    case get_discussions_by_hot([String: Any?])
    case get_discussions_by_promoted([String: Any?])
    case get_reward_fund([String])
    case get_current_median_history_price([String])
    
    var represent: String {
        switch self  {
        case .get_block(let params):
            let parameters = params.compactMap(String.cast)
            return self.jsonrpc(id: 1, method: "get_block", params: parameters)
        
        case .get_dynamic_global_properties:
            let parameters = [String]()
            return self.jsonrpc(id: 1, method: "get_dynamic_global_properties", params: parameters)
            
        case .get_accounts(let params):
            let parameters = "[\(params.compactMap(String.cast).joined(separator: ","))]"
            return self.jsonrpc(id: 1, method: "get_accounts", params: [parameters])
            
        case .get_reward_fund(let params):
            let parameters = "\(params.compactMap(String.cast).joined(separator: ","))"
            return self.jsonrpc(id: 1, method: "get_reward_fund", params: [parameters])
            
        case .get_current_median_history_price(let params):
            let parameters = "\(params.compactMap(String.cast).joined(separator: ","))"
            return self.jsonrpc(id: 1, method: "get_current_median_history_price", params: [parameters])
            
        case .get_discussions_by_blog(let params):
            let parameters = params.compactMap { (k, someval) -> String? in
                if let v = someval, let value = String.cast(v), let key = String.cast(k) {
                    return key + ":" + value
                }
                return nil
            }.joined(separator: ",")
            return self.jsonrpc(id: 1, method: "get_discussions_by_blog", params: ["{\(parameters)}"])
        
        case .get_discussions_by_feed(let params):
            let parameters = params.compactMap { (k, someval) -> String? in
                if let v = someval, let value = String.cast(v), let key = String.cast(k) {
                    return key + ":" + value
                }
                return nil
                }.joined(separator: ",")
            return self.jsonrpc(id: 1, method: "get_discussions_by_feed", params: ["{\(parameters)}"])
            
        case .get_discussions_by_trending(let params):
            let parameters = params.compactMap { (k, someval) -> String? in
                if let v = someval, let value = String.cast(v), let key = String.cast(k) {
                    return key + ":" + value
                }
                return nil
                }.joined(separator: ",")
            return self.jsonrpc(id: 1, method: "get_discussions_by_trending", params: ["{\(parameters)}"])
            
        case .get_discussions_by_created(let params):
            let parameters = params.compactMap { (k, someval) -> String? in
                if let v = someval, let value = String.cast(v), let key = String.cast(k) {
                    return key + ":" + value
                }
                return nil
                }.joined(separator: ",")
            return self.jsonrpc(id: 1, method: "get_discussions_by_created", params: ["{\(parameters)}"])
            
        case .get_discussions_by_hot(let params):
            let parameters = params.compactMap { (k, someval) -> String? in
                if let v = someval, let value = String.cast(v), let key = String.cast(k) {
                    return key + ":" + value
                }
                return nil
                }.joined(separator: ",")
            return self.jsonrpc(id: 1, method: "get_discussions_by_hot", params: ["{\(parameters)}"])
            
        case .get_discussions_by_promoted(let params):
            let parameters = params.compactMap { (k, someval) -> String? in
                if let v = someval, let value = String.cast(v), let key = String.cast(k) {
                    return key + ":" + value
                }
                return nil
                }.joined(separator: ",")
            return self.jsonrpc(id: 1, method: "get_discussions_by_promoted", params: ["{\(parameters)}"])
            
        }
    }
}

extension DatabaseRPCApi: RPCApi {
    var name: String {
        return "database_api"
    }
}
