//
//  UserService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Moya

public enum UserServiceError: Error {
    case underline(Error)
    case noSavedCredentials
    case noAccount
}

public protocol UserService {
    func accounts(with names: [String], completion: @escaping (Result<[Account]>) -> ())
    func account(completion: @escaping (Result<Account>) -> ())
    func logedQ(completion: @escaping (Result<Credentials?>) -> ())
    func login(userName: String, postingKey: String, completion: @escaping (Result<Void>) -> Void)
    func logout(completion: @escaping (Result<Void>) -> Void)
    func preparePosting(completion: @escaping (Result<Block>) -> Void)
}

struct SteemitUserService {
    private let networkService: NetworkService
    private let userDefaultsStorageSvc: UserDefaultsStorageService
    
    init() {
        let userProvider = MoyaProviders.shared.userProvider
        let feedProvider = MoyaProviders.shared.feedProvider
        
        self.networkService = SteemitNetworkService(userProvider: userProvider,
                                                        feedProvider: feedProvider)
        self.userDefaultsStorageSvc = UserDefaultsStorageService()
    }
}

extension SteemitUserService {
    private func getDynamicGlobalProperties(completion: @escaping (Result<DynGlobPropertiesRaw>) -> Void) {
        let url = Config.Endpoints.Login.url
        networkService.getDynamicGlobalProperties(url: url, completion: completion)
    }
    
    private func getBlock(block: Int64, completion: @escaping (Result<BlockRaw>) -> Void) {
        let url = Config.Endpoints.Login.url
        networkService.getBlock(url: url, block: block, completion: completion)
    }
    
    private func getAccounts(username: [String], completion: @escaping (Result<[Account]>) -> Void) {
        let url = Config.Endpoints.Login.url
        networkService.getAccounts(url: url, accounts: username) { (result: Result<[AccountRaw]>) in
            switch result {
            case .success(let accounts):
                let result = Result<[Account]>.success(accounts.map({ $0.asEntity }))
                completion(result)
            case .error(let error):
                let result = Result<[Account]>.error(UserServiceError.underline(error))
                completion(result)
            }
        }
    }
    
    // TODO: use getAccounts
    private func getAccount(username: String, completion: @escaping (Result<Account>) -> Void) {
        let url = Config.Endpoints.Login.url
        networkService.getAccounts(url: url, accounts: [username]) { (result: Result<[AccountRaw]>) in
            switch result {
            case .success(let accounts):
                if let account = accounts.first {
                    self.userDefaultsStorageSvc.save(value: account, key: Config.Storage.Keys.account, completion: { _ in })
                    
                    let result = Result<Account>.success(account.asEntity)
                    completion(result)
                } else {
                    let result = Result<Account>.error(UserServiceError.noAccount)
                    completion(result)
                }
            case .error(let error):
                let result = Result<Account>.error(UserServiceError.underline(error))
                completion(result)
            }
        }
    }
}

extension SteemitUserService: UserService {
    func accounts(with names: [String], completion: @escaping (Result<[Account]>) -> ()) {
        self.getAccounts(username: names, completion: {(res: Result<[Account]>) in
            switch res {
            case .success(let account):
                let result = Result<[Account]>.success(account)
                completion(result)
            case .error(let err):
                let result = Result<[Account]>.error(UserServiceError.underline(err))
                completion(result)
            }
        })
    }
    
    public func account(completion: @escaping (Result<Account>) -> ()) {
        userDefaultsStorageSvc.get(key: Config.Storage.Keys.account) { (res: Result<AccountRaw?>) in
            var cachedResult: Result<Account>?
            if case .success(let someAccount) = res, let account = someAccount?.asEntity {
                cachedResult = Result<Account>.success(account)
            }
            
            let secureStorageService = SecureStorageService()
            secureStorageService.get(key: Config.Storage.Keys.credentials) { (result: Result<Credentials?>) in
                switch result {
                case .success(let someCreds):
                    if let creds = someCreds {
                        _ = creds.username
                        self.getAccount(username: creds.username, completion: {(res: Result<Account>) in
                            switch res {
                            case .success(let account):
                                let result = Result<Account>.success(account)
                                completion(result)
                            case .error(let err):
                                if let result = cachedResult {
                                    completion(result)
                                } else {
                                    let result = Result<Account>.error(UserServiceError.underline(err))
                                    completion(result)
                                }
                            }
                        })
                    } else {
                        let result = Result<Account>.error(UserServiceError.noSavedCredentials)
                        completion(result)
                    }
                case .error(let error):
                    let result = Result<Account>.error(UserServiceError.underline(error))
                    completion(result)
                }
            }
        }
    }
    
    public func logedQ(completion: @escaping (Result<Credentials?>) -> ()) {
        let secureStorageService = SecureStorageService()
        secureStorageService.get(key: Config.Storage.Keys.credentials, completion: completion)
    }
    
    public func preparePosting(completion: @escaping (Result<Block>) -> Void) {
        if ApplicationReachabilitySvc.internetConnectedQ {
            getDynamicGlobalProperties { (result: Result<DynGlobPropertiesRaw>) in
                // 1
                switch result {
                case .success(let dynGlobPropertiesRaw):
                    let block_num = dynGlobPropertiesRaw.last_irreversible_block_num
                    self.getBlock(block: block_num, completion: { (result: Result<BlockRaw>) in
                        // 2
                        switch result {
                        case .success(let blockRaw):
                            let result = Result<Block>.success(blockRaw.asEntity)
                            completion(result)
                        case .error(let error):
                            let error = UserServiceError.underline(error)
                            let result = Result<Block>.error(error)
                            completion(result)
                        }
                    })
                case .error(let error):
                    let error = UserServiceError.underline(error)
                    let result = Result<Block>.error(error)
                    completion(result)
                }
            }
        } else {
            let error = UserServiceError.underline(ReachabilitySvcError.noInternetConnection)
            let result = Result<Block>.error(error)
            completion(result)
        }
    }
    
    public func login(userName: String, postingKey: String, completion: @escaping (Result<Void>) -> Void) {
        let secureStorageService = SecureStorageService()
        let credentials = Credentials(username: userName, postingKey: postingKey)
        
        secureStorageService.save(value: credentials, key: Config.Storage.Keys.credentials) { (result: Result<Credentials>) in
            switch result {
            case .success:
                let res = Result<Void>.success(())
                completion(res)
            case .error(let err):
                let res = Result<Void>.error(err)
                completion(res)
            }
        }
    }
    
    public func logout(completion: @escaping (Result<Void>) -> Void) {
        let secureStorageService = SecureStorageService()
        secureStorageService.delete(key: Config.Storage.Keys.credentials) { (result: Result<Credentials?>) in
            switch result {
            case .success:
                let result = Result<Void>.success(())
                completion(result)
            case .error(let err):
                let result = Result<Void>.error(err)
                completion(result)
            }
        }
        
        userDefaultsStorageSvc.delete(key: Config.Storage.Keys.balance, completion: { (res: Result<Double?>) in })
        userDefaultsStorageSvc.delete(key: Config.Storage.Keys.account, completion: { (res: Result<AccountRaw?>) in })
    }
}
