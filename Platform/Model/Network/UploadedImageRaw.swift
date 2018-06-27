//
//  UploadedImageRaw.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/27/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Photos

public struct SignedLinks {
    public let path: String
    public let link: String
}

public struct SignedData {
    public let path: String
    public let hash: String
    public let imageData: Data
}

public struct ImageAsset {
    public let path: String
    public let asset: PHAsset
    public let imageData: Data
}

struct UploadedImageRaw: Codable {
    let url: String
}
