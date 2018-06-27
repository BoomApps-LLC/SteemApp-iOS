//
//  NetworkBroadcastRPCApi.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/2/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

enum NetworkBroadcastRPCApi {
    case broadcast_transaction_synchronous([Int64])
    
    var represent: String {
        switch self  {
        case .broadcast_transaction_synchronous(let params):
            let parameters = params.compactMap(String.cast)
            return self.jsonrpc(id: 1, method: "broadcast_transaction_synchronous", params: parameters)
        }
    }
}

extension NetworkBroadcastRPCApi: RPCApi {
    var name: String {
        return "network_broadcast_api"
    }
}
