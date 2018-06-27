//
//  StorageService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/25/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

protocol StorageService {
    func get<T: Codable>(key: String, completion: @escaping (Result<T?>) -> ())
    func save<T: Codable>(value: T, key: String, completion: @escaping (Result<T>) -> ())
    func delete<T: Codable>(key: String, completion: @escaping (Result<T?>) -> ())
}
