//
//  Post.swift
//  Platform
//
//  Created by Siarhei Suliukou on 5/2/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public struct ActiveVote: Codable {
    public let voter: String
    public let weight: Int64
    public let rshares: Int64
    //    let percent: Int
    //    let reputation: String
    //    let time: Date
    
    init(avr: ActiveVoteRaw) {
        self.voter = avr.voter
        self.weight = avr.weight
        self.rshares = avr.rshares
    }
}

public struct Post {
    public let id: Int64
    public let author: String
    public let permlink: String
    public let category: String
    public let parent_author: String
    public let parent_permlink: String
    public let title: String
    public let body: String
    public let bodyPlain: String
    public let json_metadata: String
    //    let last_update: Date
    public let created: Date
    //    let active: Date
    //    let last_payout: Date
    //    let depth: Int
    public let children: Int
    //    let net_rshares: Int
    //    let abs_rshares: Int
    //    let vote_rshares: Int
    //    let children_abs_rshares: Int
    //    let total_vote_weight: Int
    //    let reward_weight: Int
    public let total_payout_value: String
    public let curator_payout_value: String
    //    let author_rewardsInt: Int
    public let net_votes: Int
    //    let root_author: String
    //    let root_permlink: String
    //    let max_accepted_payout: String
    //    let percent_steem_dollars: Int
    public let allow_replies: Bool
    public let allow_votes: Bool
    public let allow_curation_rewards: Bool
    //    let beneficiaries: [String]
    public let url: String
    //    let root_title: String
    //    let pending_payout_value: String
    //    let total_pending_payout_value: String
    public let active_votes: [ActiveVote]
    public let replies: [String]
    //    let author_reputation: Int
    //    let promoted: String
    //    let body_length: Int
    //    let reblogged_by: [String]
    
    public var cover_image: String?
}

extension Post {
    public var createdText: String {
        var result: String = ""
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: self.created, to: Date())
        let years = dateComponents.year ?? 0
        let months = dateComponents.month ?? 0
        let days = dateComponents.day ?? 0
        let hours = dateComponents.hour ?? 0
        
        if years > 0 {
            result = (years == 1 ? "\(years) year ago" : "\(years) years ago")
        } else if months > 0 {
            result = (months == 1 ? "\(months) month ago" : "\(months) months ago")
        } else if days > 0 {
            result = (days == 1 ? "\(days) day ago" : "\(days) days ago")
        } else {
            result = (hours == 1 ? "\(hours) hour ago" : "\(hours) hours ago")
        }
        
        return result
    }
}

public enum PostBodyFormat: String {
    case html, markdown
}

private struct JsonMetadata: Decodable {
    let tags: [String]
    let links: [String]
    let image: [String]
    let format: PostBodyFormat
    
    enum CodingKeys: String, CodingKey {
        case tags = "tags"
        case links = "links"
        case image = "image"
        case format = "format"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tags = try container.decodeIfPresent([String].self, forKey: CodingKeys.tags)
        let links = try container.decodeIfPresent([String].self, forKey: CodingKeys.links)
        let images = try container.decodeIfPresent([String].self, forKey: CodingKeys.image)
        let format = try container.decodeIfPresent(String.self, forKey: CodingKeys.format)
        
        self.tags = tags ?? []
        self.links = links ?? []
        self.image = images ?? []
        self.format = PostBodyFormat(rawValue: format ?? "markdown") ?? PostBodyFormat.html
    }
}

extension PostRaw {
    public var cover_image: String? {
        var result: String? = nil
        let decoder = JSONDecoder()
        
        if let data = self.json_metadata.data(using: .utf8) {
            let json = try? decoder.decode(JsonMetadata.self, from: data)
            result = json?.image.first
        }
        
        return result
    }
    
    public var htmlQ: Bool {
        var result: Bool = false
        let decoder = JSONDecoder()
        
        if let data = self.json_metadata.data(using: .utf8) {
            let json = try? decoder.decode(JsonMetadata.self, from: data)
            result = (json?.format == PostBodyFormat.html)
        }
        
        return result
    }
}
