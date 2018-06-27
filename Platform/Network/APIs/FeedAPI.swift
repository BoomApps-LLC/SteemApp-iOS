//
//  FeedAPI.swift
//  Platform
//
//  Created by Siarhei Suliukou on 5/3/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum FeedAPI {
    case getBlog(endpointURL: URL, params: RPCGetBlogParams, addparam: RPCGetBlogAddParams?)
    case getFeed(endpointURL: URL, params: RPCGetFeedParams, addparam: RPCGetFeedAddParams?)
    case getTrending(endpointURL: URL, params: RPCGetTrendingParams, addparam: RPCGetTrendingAddParams?)
    case getCreated(endpointURL: URL, params: RPCGetCreatedParams, addparam: RPCGetCreatedAddParams?)
    case getHot(endpointURL: URL, params: RPCGetHotParams, addparam: RPCGetHotAddParams?)
    case getPromoted(endpointURL: URL, params: RPCGetPromotedParams, addparam: RPCGetPromotedAddParams?)
    case getRewardFund(endpointURL: URL, params: [String])
    case getCurrentMedianHistoryPrice(endpointURL: URL, params: [String])
}

extension FeedAPI: Moya.TargetType {
    var path: String {
        switch self {
        case .getBlog, .getFeed, .getTrending, .getCreated, .getHot, .getPromoted,
             .getRewardFund, .getCurrentMedianHistoryPrice:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getBlog, .getFeed, .getTrending, .getCreated, .getHot, .getPromoted,
             .getRewardFund, .getCurrentMedianHistoryPrice:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Moya.Task {
        switch self {
        case .getBlog, .getFeed, .getTrending, .getCreated, .getHot, .getPromoted,
             .getRewardFund, .getCurrentMedianHistoryPrice:
            return .requestData(body.utf8Encoded)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        switch self {
        case .getBlog(let url, _, _):
            return url
        case .getRewardFund(let url, _):
            return url
        case .getCurrentMedianHistoryPrice(let url, _):
            return url
        case .getFeed(let url, _, _):
            return url
        case .getTrending(let url, _, _):
            return url
        case .getCreated(let url, _, _):
            return url
        case .getHot(let url, _, _):
            return url
        case .getPromoted(let url, _, _):
            return url
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getBlog, .getFeed, .getTrending, .getCreated, .getHot, .getPromoted,
             .getRewardFund, .getCurrentMedianHistoryPrice:
            return [:]
        }
    }
    
    var validate: Bool {
        return false
    }
}

extension FeedAPI: RPCConvertable {
    var body: String {
        switch self {
        case .getRewardFund(_, let params):
            return DatabaseRPCApi.get_reward_fund(params).represent
            
        case .getCurrentMedianHistoryPrice(_, let params):
            return DatabaseRPCApi.get_current_median_history_price(params).represent
        
        case .getBlog(endpointURL: _, let params, let addparams):
            return DatabaseRPCApi.get_discussions_by_blog(["tag": params.tag,
                                                           "limit" : params.limit,
                                                           "start_author" : addparams?.start_author,
                                                           "start_permlink" : addparams?.start_permlink]).represent
            
        case .getFeed(endpointURL: _, let params, let addparam):
            return DatabaseRPCApi.get_discussions_by_feed(["tag": params.tag,
                                                           "limit" : params.limit,
                                                           "start_author" : addparam?.start_author,
                                                           "start_permlink" : addparam?.start_permlink]).represent
        case .getTrending(_, let params, let addparam):
            return DatabaseRPCApi.get_discussions_by_trending(["tag": params.tag,
                                                               "limit" : params.limit,
                                                               "start_author" : addparam?.start_author,
                                                               "start_permlink" : addparam?.start_permlink]).represent
        case .getCreated(_, let params, let addparam):
            return DatabaseRPCApi.get_discussions_by_created(["tag": params.tag,
                                                           "limit" : params.limit,
                                                           "start_author" : addparam?.start_author,
                                                           "start_permlink" : addparam?.start_permlink]).represent
        case .getHot(_, let params, let addparam):
            return DatabaseRPCApi.get_discussions_by_hot(["tag": params.tag,
                                                           "limit" : params.limit,
                                                           "start_author" : addparam?.start_author,
                                                           "start_permlink" : addparam?.start_permlink]).represent
        case .getPromoted(_, let params, let addparam):
            return DatabaseRPCApi.get_discussions_by_promoted(["tag": params.tag,
                                                           "limit" : params.limit,
                                                           "start_author" : addparam?.start_author,
                                                           "start_permlink" : addparam?.start_permlink]).represent
        }
    }
}

extension FeedAPI: Validatable {
    var validations: [DataRequest.Validation] {
        return [ValidStatusCodes.standart]
    }
}

extension FeedAPI: Serializable {
    var serializer: Parseble {
        switch self {
        default:
            return JSONBoxSerializer()
        }
    }
}
