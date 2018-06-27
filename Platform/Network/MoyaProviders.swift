//
//  MoyaRequestProvider.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Moya
import Alamofire

struct MoyaProviders {
    static let shared = MoyaProviders()
    let userProvider: MoyaProvider<UserAPI>
    let walletProvider: MoyaProvider<WalletAPI>
    let feedProvider: MoyaProvider<FeedAPI>
    
    private init() {
        self.userProvider = MoyaProvider<UserAPI>(plugins: [MoyaValidationPlugin()])
        self.userProvider.manager.adapter = UserRequestAdapter()
        
        self.walletProvider = MoyaProvider<WalletAPI>(plugins: [MoyaValidationPlugin()])
        //self.walletProvider.manager.adapter = UserRequestAdapter()
        self.feedProvider = MoyaProvider<FeedAPI>(plugins: [MoyaValidationPlugin()])
    }
}

internal struct UserRequestAdapter {
}

extension UserRequestAdapter: RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
//        var resultRequest = urlRequest
//        var token: String = "123456"
        
//        let headerField = "Authorization"
//
//        if let _ = urlRequest.value(forHTTPHeaderField: headerField) {
//            resultRequest.setValue(token, forHTTPHeaderField: headerField)
//        } else {
//            resultRequest.addValue(token, forHTTPHeaderField: headerField)
//        }
//
        return urlRequest
    }
}
