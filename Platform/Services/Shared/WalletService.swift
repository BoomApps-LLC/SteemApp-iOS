//
//  WalletService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/21/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation


public enum WalletServiceError: Error {
    case underline(Error)
    case noEnoughData
    case noSavedCredentials
    case noAccount
    case noHelloacm
    case noCoinmarketcap
}

public protocol WalletService {
    func balance(completion: @escaping (Result<Double>) -> Void)
    func balanceCache(completion: @escaping (Result<Double>) -> Void)
}

struct SteemitWalletService {
    private let userService: UserService
    private let walletNetworkService: WalletNetworkService
    private let networkService: NetworkService
    private let userDefaultsStorageSvc: UserDefaultsStorageService
    
    init() {
        let walletProvider = MoyaProviders.shared.walletProvider
        let userProvider = MoyaProviders.shared.userProvider
        let feedProvider = MoyaProviders.shared.feedProvider
        
        self.walletNetworkService = SteemitWalletNetworkService(provider: walletProvider)
        self.userService = SteemitUserService()
        self.networkService = SteemitNetworkService(userProvider: userProvider,
                                                    feedProvider: feedProvider)
        self.userDefaultsStorageSvc = UserDefaultsStorageService()
    }
}


extension SteemitWalletService: WalletService {
    func balanceCache(completion: @escaping (Result<Double>) -> Void) {
        userDefaultsStorageSvc.get(key: Config.Storage.Keys.balance) { (res: Result<Double?>) in
            var balance: Double = 0.0
            if case .success(let bal) = res {
                balance = bal ?? 0.0
            }

            let result = Result<Double>.success(balance)
            completion(result)
        }
    }
    
    public func balance(completion: @escaping (Result<Double>) -> Void) {
        if ApplicationReachabilitySvc.internetConnectedQ {
            var res: Result<Double>?
            var sbds: Double = 0.0
            var vesting_shares: Double = 0.0
            var steems: Double = 0.0
            var total_vesting_fund_steem: Double = 0.0
            var total_vesting_shares: Double = 1.0
            var price_usd_SBD2USD: Double = 0.0
            var price_usd_STEEM2USD: Double = 0.0
            
            let dispatchGroup = DispatchGroup()
            
            dispatchGroup.enter()
            userService.account(completion: { (result: Result<Account>) in
                switch result {
                case .success(let account):
                    sbds = account.sbd_balance + account.savings_sbd_balance
                    vesting_shares = account.vesting_shares
                    steems =  account.balance + account.savings_balance
                case .error:
                    let error = WalletServiceError.noAccount
                    res = Result<Double>.error(error)
                }

                dispatchGroup.leave()
            })

            dispatchGroup.enter()
            let url2 = Config.Endpoints.Wallet.coinmarketcapUrlSBD2USD
            self.walletNetworkService.coinmarketcapSBD2USD(url2, completion: { (result: Result<CoinmarketcapsRaw>) in
                switch result {
                case .success(let coinmarketcaps):
                    price_usd_SBD2USD = coinmarketcaps.items.first?.price_usd.double ?? 0.0
                case .error:
                    let error = WalletServiceError.noCoinmarketcap
                    res = Result<Double>.error(error)
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            let url3 = Config.Endpoints.Wallet.coinmarketcapUrlSTEEM2USD
            self.walletNetworkService.coinmarketcapSTEEM2USD(url3, completion: { (result: Result<CoinmarketcapsRaw>) in
                switch result {
                case .success(let coinmarketcaps):
                    price_usd_STEEM2USD = coinmarketcaps.items.first?.price_usd.double ?? 0.0
                case .error:
                    let error = WalletServiceError.noCoinmarketcap
                    res = Result<Double>.error(error)
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.enter()
            let url = Config.Endpoints.Login.url
            networkService.getDynamicGlobalProperties(url: url, completion: { (result: Result<DynGlobPropertiesRaw>) in
                switch result {
                case .success(let dynGlobProperties):
                    total_vesting_fund_steem = dynGlobProperties.total_vesting_fund_steem.double
                    total_vesting_shares = dynGlobProperties.total_vesting_shares.double
                case .error:
                    let error = WalletServiceError.noCoinmarketcap
                    res = Result<Double>.error(error)
                }
                
                dispatchGroup.leave()
            })
            
            dispatchGroup.notify(queue: .main, execute: {
                if res == nil {
                    let sum = sbds * price_usd_SBD2USD +
                        (steems + total_vesting_fund_steem * vesting_shares / total_vesting_shares) * price_usd_STEEM2USD
                    
                    res = Result<Double>.success(sum)
                    
                    self.userDefaultsStorageSvc.save(value: sum, key: Config.Storage.Keys.balance, completion: { _ in
                        
                    })
                }
                
                completion(res!)
            })
        } else {
            let error = WalletServiceError.underline(ReachabilitySvcError.noInternetConnection)
            let result = Result<Double>.error(error)
            completion(result)
        }
    }
}
