//
//  EntityConvertable.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

protocol EntityConvertable {
    associatedtype EntityType
    var asEntity: EntityType { get }
}
