//
//  PostRaw.swift
//  Platform
//
//  Created by Siarhei Suliukou on 5/2/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

struct ActiveVoteRaw: Codable {
    let voter: String
    let weight: Int64
    let rshares: Int64
//    let percent: Int
//    let reputation: String
//    let time: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.voter = try container.decode(String.self, forKey: .voter)
        self.weight = try container.decode(Int64.self, forKey: .weight)
        
        // Need to do it because sometime they send Int or String
        if let rshares = try? container.decode(Int64.self, forKey: CodingKeys.rshares) {
            self.rshares = rshares
        } else if let str_rshares = try? container.decode(String.self, forKey: CodingKeys.rshares), let rshares = Int64(str_rshares) {
            self.rshares = rshares
        } else {
            self.rshares = 0
        }
    }
}

struct PostRaw: Codable {
    let id: Int64
    let author: String
    let permlink: String
    let category: String
    let parent_author: String
    let parent_permlink: String
    let title: String
    let body: String
    let json_metadata: String
//    let last_update: Date
    let created: Date
//    let active: Date
//    let last_payout: Date
//    let depth: Int
    let children: Int
//    let net_rshares: Int
//    let abs_rshares: Int
//    let vote_rshares: Int
//    let children_abs_rshares: Int
//    let total_vote_weight: Int
//    let reward_weight: Int
    let total_payout_value: String
    let curator_payout_value: String
//    let author_rewards: Int
    let net_votes: Int
//    let root_author: String
//    let root_permlink: String
//    let max_accepted_payout: String
//    let percent_steem_dollars: Int
    let allow_replies: Bool
    let allow_votes: Bool
    let allow_curation_rewards: Bool
//    let beneficiaries: [String]
    let url: String
//    let root_title: String
//    let pending_payout_value: String
//    let total_pending_payout_value: String
    let active_votes: [ActiveVoteRaw]
    let replies: [String]
//    let author_reputation: Int
//    let promoted: String
//    let body_length: Int
//    let reblogged_by: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case permlink
        case category
        case parent_author
        case parent_permlink
        case title
        case body
        case json_metadata
        //    let last_update: Date
        case created
        //    let active: Date
        //    let last_payout: Date
        //    let depth: Int
        case children
        // case net_rshares
        //    let abs_rshares: Int
        //    let vote_rshares: Int
        //    let children_abs_rshares: Int
        //    let total_vote_weight: Int
        //    let reward_weight: Int
        case total_payout_value
        case curator_payout_value
        //    let author_rewardsInt: Int
        case net_votes
        //    let root_author: String
        //    let root_permlink: String
        //    let max_accepted_payout: String
        //    let percent_steem_dollars: Int
        case allow_replies
        case allow_votes
        case allow_curation_rewards
        //    let beneficiaries: [String]
        case url
        //    let root_title: String
        //    let pending_payout_value: String
        //    let total_pending_payout_value: String
        case active_votes
        case replies
        //    let author_reputation: Int
        //    let promoted: String
        //    let body_length: Int
        //    let reblogged_by: [String]
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(Int64.self, forKey: .id)
        self.author = try container.decode(String.self, forKey: .author)
        self.permlink = try container.decode(String.self, forKey: .permlink)
        self.category = try container.decode(String.self, forKey: .category)
        self.parent_author = try container.decode(String.self, forKey: .parent_author)
        self.parent_permlink = try container.decode(String.self, forKey: .parent_permlink)
        self.title = try container.decode(String.self, forKey: .title)
        self.body = try container.decode(String.self, forKey: .body)
        self.json_metadata = try container.decode(String.self, forKey: .json_metadata)
        //    let last_update: Date
        self.created = try container.decode(Date.self, forKey: .created)
        //    let active: Date
        //    let last_payout: Date
        //    let depth: Int
        self.children = try container.decode(Int.self, forKey: .children)
        //self.net_rshares = try container.decode(Int.self, forKey: .net_rshares)
        //    let net_rshares: Int
        //    let abs_rshares: Int
        //    let vote_rshares: Int
        //    let children_abs_rshares: Int
        //    let total_vote_weight: Int
        //    let reward_weight: Int
        self.total_payout_value = try container.decode(String.self, forKey: .total_payout_value)
        self.curator_payout_value = try container.decode(String.self, forKey: .curator_payout_value)
        //    let author_rewardsInt: Int
        self.net_votes = try container.decode(Int.self, forKey: .net_votes)
        //    let root_author: String
        //    let root_permlink: String
        //    let max_accepted_payout: String
        //    let percent_steem_dollars: Int
        self.allow_replies = try container.decode(Bool.self, forKey: .allow_replies)
        self.allow_votes = try container.decode(Bool.self, forKey: .allow_votes)
        self.allow_curation_rewards = try container.decode(Bool.self, forKey: .allow_curation_rewards)
        //    let beneficiaries: [String]
        self.url = try container.decode(String.self, forKey: .url)
        //    let root_title: String
        //    let pending_payout_value: String
        //    let total_pending_payout_value: String
        self.active_votes = try container.decode([ActiveVoteRaw].self, forKey: .active_votes)
        self.replies = try container.decode([String].self, forKey: .replies)
        //    let author_reputation: Int
        //    let promoted: String
        //    let body_length: Int
        //    let reblogged_by: [String]

    }
}

extension PostRaw: EntityConvertable {
    typealias EntityType = Post
    
    var asEntity: Post {
        let bodyPlain: String = body
        
        return Post(id: id, author: author, permlink: permlink, category: category,
                    parent_author: parent_author, parent_permlink: parent_permlink,
                    title: title, body: body, bodyPlain: bodyPlain, json_metadata: json_metadata, created: created,
                    children: children, total_payout_value: total_payout_value,
                    curator_payout_value: curator_payout_value, net_votes: net_votes,
                    allow_replies: allow_replies,
                    allow_votes: allow_votes, allow_curation_rewards: allow_curation_rewards, url: url,
                    active_votes: active_votes.map(ActiveVote.init),
                    replies: replies, cover_image: self.cover_image)
    }
    
    private var bodyToPlainText: String {
        if self.htmlQ {
            return self.body.htmlToFlatText
        }
        
        return self.body
//            .replacingOccurrences(of: "#", with: "")
//            .replacingOccurrences(of: "*", with: "")
//            .replacingOccurrences(of: "_", with: "")
//            .replacingOccurrences(of: "~", with: "")
//            .replacingOccurrences(of: "⋅", with: "")
//            .replacingOccurrences(of: "-", with: "")
//            .replacingOccurrences(of: "+", with: "")
//            .replacingOccurrences(of: "!\\[*\\]", with: "", options: String.CompareOptions.regularExpression)
//            .replacingOccurrences(of: "[", with: "")
//            .replacingOccurrences(of: "]", with: "")
//            .replacingOccurrences(of: "\\n", with: " ", options: String.CompareOptions.regularExpression)
//            .replacingOccurrences(of: "^", with: "", options: String.CompareOptions.regularExpression)
    }
}
