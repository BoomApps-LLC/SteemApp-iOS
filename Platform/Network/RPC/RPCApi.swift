//
//  RPCApi.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

protocol RPCConvertable {
    var body: String { get }
}

protocol RPCApi {
    var name: String { get }
}

extension RPCApi {
    func jsonrpc(id: Int, method: String, params: [String]) -> String {
        let parametersString = params.joined(separator: ",")
        return "{ \"id\": \(id), \"jsonrpc\": \"2.0\", \"method\": \"call\", \"params\": [\"\(self.name)\", \"\(method)\", [\(parametersString)]] }"
    }
}
