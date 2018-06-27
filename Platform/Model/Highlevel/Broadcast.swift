//
//  Broadcast.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/2/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public struct BroadcastComment {
    public let parent_author: String
    public let parent_permlink: String
    public let author: String
    public let permlink: String
    public let title: String
    public let body: String
    public let tags: [String]
    public let links: [String]
    
    public init(parent_author: String, parent_permlink: String, author: String, permlink: String,
                title: String, body: String, tags: [String], links: [String]) {
        self.parent_author = parent_author
        self.parent_permlink = parent_permlink
        self.author = author
        self.permlink = permlink
        self.title = title
        self.body = body
        self.tags = tags
        self.links = links
    }
    
    var json_metadata: String {
        let tags = self.tags.compactMap(String.cast).joined(separator: ",")
        let links = self.links.compactMap(String.cast).joined(separator: ",")
        
        return "{\"tags\": [\(tags)], \"links\": [\(links)], \"image\": [\(links)], \"app\": \"ios-steemitapp/0.1\", \"format\": \"html\"}"
    }
}

public struct BroadcastCommentOptions {
    public let author: String
    public let permlink: String
    public let max_accepted_payout: String
    public let percent_steem_dollars: Int
    public let allow_votes: Bool
    public let allow_curation_rewards: Bool
    public let extensions: [String]
    
    public init(author: String, permlink: String, max_accepted_payout: String, percent_steem_dollars: Int,
                allow_votes: Bool, allow_curation_rewards: Bool, extensions: [String]) {
        
        self.author = author
        self.permlink = permlink
        self.max_accepted_payout = max_accepted_payout
        self.percent_steem_dollars = percent_steem_dollars
        self.allow_votes = allow_votes
        self.allow_curation_rewards = allow_curation_rewards
        self.extensions = extensions
    }
}

public struct BroadcastVote {
    public let voter: String
    public let author: String
    public let permlink: String
    public let weight: Int
    
    public init(voter: String, author: String, permlink: String, weight: Int) {
        self.voter = voter
        self.author = author
        self.permlink = permlink
        self.weight = weight
    }
}

public struct Comment: Encodable {
    let parent_author: String
    let parent_permlink: String
    let author: String
    let permlink: String
    let title: String
    let body: String
    
    private var json_metadata: String {
        let tagsString = self.tags.compactMap(String.cast).joined(separator: ",")
        let linksString = self.links.compactMap(String.cast).joined(separator: ",")
        
        return "{\"tags\":[\(tagsString)],\"links\":[\(linksString)],\"app\":\"steemit/0.1\",\"format\":\"html\"}"
    }
    
    enum CodingKeys: String, CodingKey {
        case parent_author
        case parent_permlink
        case author
        case permlink
        case title
        case body
        case json_metadata
    }
    
    public func encode(to encoder: Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: CodingKeys.self)
        try keyedContainer.encode(parent_author, forKey: .parent_author)
        try keyedContainer.encode(parent_permlink, forKey: .parent_permlink)
        try keyedContainer.encode(author, forKey: .author)
        try keyedContainer.encode(permlink, forKey: .permlink)
        try keyedContainer.encode(title, forKey: .title)
        try keyedContainer.encode(body, forKey: .body)
        try keyedContainer.encode(json_metadata, forKey: .json_metadata)
    }
    
    let tags: [String]
    let links: [String]
}

public struct CommentOperation: Encodable {
    let name = "comment"
    let comment: Comment
    
    public func encode(to encoder: Encoder) throws {
        var unkeyedContainer = encoder.unkeyedContainer()
        try unkeyedContainer.encode(name)
        try unkeyedContainer.encode(comment)
    }
}

public struct Broadcast: Encodable {
    let ref_block_num: Int64
    let ref_block_prefix: Int64
    let expiration: String
    let extensions: [String]
    let signatures: [String]
    
    let operations: CommentOperation
}
