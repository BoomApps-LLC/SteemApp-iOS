//
//  SharedNote.swift
//  Platform
//
//  Created by Siarhei Suliukou on 3/12/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Photos

public final class Note: Codable {
    public var title: String?
    public var body: String?
    public var tags = [String]()
    public var assets = [String: String]()
    
    public init() {
        title = ""
        body = ""
    }
}
