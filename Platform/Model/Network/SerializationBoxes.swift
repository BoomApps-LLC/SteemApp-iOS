//
//  SerializationBoxes.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/2/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

struct ResultBox<A: Codable>: Codable {
    //let id: Int64
    //let jsonrpc: String
    let result: A
    
    enum CodingKeys: String, CodingKey {
        //case id
        //case jsonrpc
        case result
    }
}

struct ErrorBox: Codable {
    //let id: Int64
    let error: SerializerErrorDescription
    
    enum CodingKeys: String, CodingKey {
        //case id
        case error
    }
}

struct SerializerErrorDescription: Codable {
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
    }
}
