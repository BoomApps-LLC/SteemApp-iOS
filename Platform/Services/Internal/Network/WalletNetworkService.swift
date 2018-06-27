//
//  WalletNetworkService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/21/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Moya

protocol WalletNetworkService {
    func helloacm(_ url: URL, completion: @escaping (Result<HelloacmRaw>) ->  Void)
    func coinmarketcapSBD2USD(_ url: URL, completion: @escaping (Result<CoinmarketcapsRaw>) ->  Void)
    func coinmarketcapSTEEM2USD(_ url: URL, completion: @escaping (Result<CoinmarketcapsRaw>) ->  Void)
}

struct SteemitWalletNetworkService {
    private let provider: MoyaProvider<WalletAPI>
    
    init(provider: MoyaProvider<WalletAPI>) {
        self.provider = provider
    }
}

extension SteemitWalletNetworkService: WalletNetworkService {
    func helloacm(_ url: URL, completion: @escaping (Result<HelloacmRaw>) -> Void) {
        let helloacm = WalletAPI.helloacm(endpointURL: url)
        send(helloacm, completion: completion)
    }
    
    func coinmarketcapSBD2USD(_ url: URL, completion: @escaping (Result<CoinmarketcapsRaw>) ->  Void) {
        let coinmarketcap = WalletAPI.coinmarketcapSBD2USD(endpointURL: url)
        send(coinmarketcap, completion: completion)
    }
    
    func coinmarketcapSTEEM2USD(_ url: URL, completion: @escaping (Result<CoinmarketcapsRaw>) ->  Void) {
        let coinmarketcap = WalletAPI.coinmarketcapSTEEM2USD(endpointURL: url)
        send(coinmarketcap, completion: completion)
    }
    
    private func send<T: Codable>(_ request: WalletAPI, completion: @escaping (Result<T>) -> Void) {
        provider.request(request) { result in
            switch result {
            case .success(let response):
                do {
                    let object: T = try request.serializer.parse(responseData: response)
                    completion(Result(value: object))
                } catch let serializerError as SerializerError {
                    completion(Result(error: serializerError))
                } catch {
                    completion(Result(error: NetworkError.parsing))
                }
                
            case .failure(let error):
                completion(Result(error: NetworkError.underline(error)))
            }
        }
    }
}
