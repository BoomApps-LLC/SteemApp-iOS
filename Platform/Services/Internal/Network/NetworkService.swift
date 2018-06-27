//
//  UserNetworkService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Moya

public enum NetworkError: Error {
    case unknown
    case unauthorized
    case parsing
    case underline(Error)
}

typealias RPCGetBlogParams = (tag: String, limit: Int)
typealias RPCGetBlogAddParams = (start_author: String, start_permlink: String)

typealias RPCGetFeedParams = (tag: String, limit: Int)
typealias RPCGetFeedAddParams = (start_author: String, start_permlink: String)

typealias RPCGetTrendingParams = (tag: String, limit: Int)
typealias RPCGetTrendingAddParams = (start_author: String, start_permlink: String)

typealias RPCGetCreatedParams = (tag: String, limit: Int)
typealias RPCGetCreatedAddParams = (start_author: String, start_permlink: String)

typealias RPCGetHotParams = (tag: String, limit: Int)
typealias RPCGetHotAddParams = (start_author: String, start_permlink: String)

typealias RPCGetPromotedParams = (tag: String, limit: Int)
typealias RPCGetPromotedAddParams = (start_author: String, start_permlink: String)


protocol NetworkService {
    func login(url: URL, userName: String, password: String, completion: @escaping (Result<AccountRaw>) ->  Void)
    func getBlock(url: URL, block: Int64, completion: @escaping (Result<BlockRaw>) ->  Void)
    func getAccounts(url: URL, accounts: [String], completion: @escaping (Result<[AccountRaw]>) ->  Void)
    func getDynamicGlobalProperties(url: URL, completion: @escaping (Result<DynGlobPropertiesRaw>) ->  Void)
    func getRewardFund(url: URL, params: [String], completion: @escaping (Result<RewardFundRaw>) -> Void)
    func getCurrentMedianHistoryPrice(url: URL, params: [String], completion: @escaping (Result<CurrentMedianPriceRaw>) -> Void)
    func getBlog(url: URL, params: RPCGetBlogParams, addparam: RPCGetBlogAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void)
    func getFeed(url: URL, params: RPCGetFeedParams, addparam: RPCGetFeedAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void)
    func getTrending(url: URL, params: RPCGetTrendingParams, addparam: RPCGetTrendingAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void)
    func getCreated(url: URL, params: RPCGetCreatedParams, addparam: RPCGetCreatedAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void)
    func getHot(url: URL, params: RPCGetHotParams, addparam: RPCGetHotAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void)
    func getPromoted(url: URL, params: RPCGetPromotedParams, addparam: RPCGetPromotedAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void)
    
}

struct SteemitNetworkService {
    private let userProvider: MoyaProvider<UserAPI>
    private let feedProvider: MoyaProvider<FeedAPI>
    
    init(userProvider: MoyaProvider<UserAPI>, feedProvider: MoyaProvider<FeedAPI>) {
        self.userProvider = userProvider
        self.feedProvider = feedProvider
    }
}

extension SteemitNetworkService: NetworkService {
    func getCurrentMedianHistoryPrice(url: URL, params: [String], completion: @escaping (Result<CurrentMedianPriceRaw>) -> Void) {
        let getCurrentMedianHistoryPrice = FeedAPI.getCurrentMedianHistoryPrice(endpointURL: url, params: [])
        send(getCurrentMedianHistoryPrice, completion: completion)
    }
    
    func getRewardFund(url: URL, params: [String], completion: @escaping (Result<RewardFundRaw>) -> Void) {
        let getRewardFund = FeedAPI.getRewardFund(endpointURL: url, params: params)
        send(getRewardFund, completion: completion)
    }
    
    func getBlog(url: URL, params: RPCGetBlogParams, addparam: RPCGetBlogAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void) {
        let getBlog = FeedAPI.getBlog(endpointURL: url, params: params, addparam: addparam)
        send(getBlog, completion: completion)
    }
    
    func getFeed(url: URL, params: RPCGetFeedParams, addparam: RPCGetFeedAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void) {
        let getFeed = FeedAPI.getFeed(endpointURL: url, params: params, addparam: addparam)
        send(getFeed, completion: completion)
    }
    
    func getTrending(url: URL, params: RPCGetTrendingParams, addparam: RPCGetTrendingAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void) {
        let getTrending = FeedAPI.getTrending(endpointURL: url, params: params, addparam: addparam)
        send(getTrending, completion: completion)
    }
    
    func getCreated(url: URL, params: RPCGetCreatedParams, addparam: RPCGetTrendingAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void) {
        let getCreated = FeedAPI.getCreated(endpointURL: url, params: params, addparam: addparam)
        send(getCreated, completion: completion)
    }
    
    func getHot(url: URL, params: RPCGetTrendingParams, addparam: RPCGetTrendingAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void) {
        let getHot = FeedAPI.getHot(endpointURL: url, params: params, addparam: addparam)
        send(getHot, completion: completion)
    }
    
    func getPromoted(url: URL, params: RPCGetTrendingParams, addparam: RPCGetTrendingAddParams?, completion: @escaping (Result<[PostRaw]>) -> Void) {
        let getPromoted = FeedAPI.getPromoted(endpointURL: url, params: params, addparam: addparam)
        send(getPromoted, completion: completion)
    }
    
    func getAccounts(url: URL, accounts: [String], completion: @escaping (Result<[AccountRaw]>) ->  Void) {
        let getAccounts = UserAPI.getAccounts(endpointURL: url, accounts: accounts)
        send(getAccounts, completion: completion)
    }
    
    func getDynamicGlobalProperties(url: URL, completion: @escaping (Result<DynGlobPropertiesRaw>) -> Void) {
        let getDynamicGlobalProperties = UserAPI.getDynamicGlobalProperties(endpointURL: url)
        send(getDynamicGlobalProperties, completion: completion)
    }
    
    func getBlock(url: URL, block: Int64, completion: @escaping (Result<BlockRaw>) -> Void) {
        let getBlock = UserAPI.getBlock(endpointURL: url, block: block)
        send(getBlock, completion: completion)
    }
    
    func login(url: URL, userName: String, password: String, completion: @escaping (Result<AccountRaw>) ->  Void) {
        let login = UserAPI.login(endpointURL: url, userName: userName, password: password)
        send(login, completion: completion)
    }
    
    private func send<T: Codable>(_ request: UserAPI, completion: @escaping (Result<T>) -> Void) {
        send(provider: userProvider, request: request, completion: completion)
    }
    
    private func send<T: Codable>(_ request: FeedAPI, completion: @escaping (Result<T>) -> Void) {
        send(provider: feedProvider, request: request, completion: completion)
    }
    
    private func send<T: Codable, AP: Moya.TargetType & Serializable>(provider: MoyaProvider<AP>,
                                                       request: AP,
                                                       completion: @escaping (Result<T>) -> Void) {
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
