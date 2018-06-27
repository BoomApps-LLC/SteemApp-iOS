//
//  SecureStorageService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 2/7/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import KeychainAccess

public enum SecureStorageServiceError: Error {
    case underline(Error)
}

fileprivate struct Constants {
    
    static var queueLabel: String {
        return "com.storage.secureStorageService"
    }
    
    static var serviceName: String {
        return "com.steemit.storage.keychain.name"
    }
}

struct SecureStorageService: StorageService {
    
    private static let queue = DispatchQueue(label: Constants.queueLabel, attributes: .concurrent)
    private let keychain = Keychain(service: Constants.serviceName)
    
    private struct Box<T: Codable>: Codable {
        let some: T
    }
    
    func save<T: Codable>(value: T, key: String, completion: @escaping (Result<T>) -> ()) {
        type(of: self).queue.async(flags: .barrier) {
            do {
                let preparedObject = Box<T?>(some: value)
                let jsonEncoder = JSONEncoder(formatter: Config.Formatters.Date.standart)
                let jsonData = try jsonEncoder.encode(preparedObject)
                
                self.keychain[data: key] = jsonData
                
                DispatchQueue.main.async {
                    let result = Result<T>(value: value)
                    completion(result)
                }
            } catch let error {
                let castedError = SecureStorageServiceError.underline(error)
                DispatchQueue.main.async {
                    let result = Result<T>(error: castedError)
                    completion(result)
                }
            }
        }
    }
    
    func delete<T: Codable>(key: String, completion: @escaping (Result<T?>) -> ()) {
        get(key: key) { (result: Result<T?>) in
            switch result {
            case .success:
                type(of: self).queue.async(flags: .barrier) {
                    self.keychain[data: key] = nil
                    
                    DispatchQueue.main.async {
                        let result = Result<T?>(value: nil)
                        completion(result)
                    }
                }
            case .error(let error):
                let castedError = SecureStorageServiceError.underline(error)
                DispatchQueue.main.async {
                    let result = Result<T?>(error: castedError)
                    completion(result)
                }
            }
        }
    }
    
    func get<T: Codable>(key: String, completion: @escaping (Result<T?>) -> ()) {
        type(of: self).queue.sync {
            do {
                let jsonDecoder = JSONDecoder(formatter: Config.Formatters.Date.standart)
                
                if let jsonData = try self.keychain.getData(key) {
                    let object = try jsonDecoder.decode(Box<T?>.self, from: jsonData)
                    DispatchQueue.main.async {
                        let result = Result<T?>(value: object.some)
                        completion(result)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        let result = Result<T?>(value: nil)
                        completion(result)
                    }
                }
            } catch let error {
                let castedError = SecureStorageServiceError.underline(error)
                DispatchQueue.main.async {
                    let result = Result<T?>(error: castedError)
                    completion(result)
                }
            }
            
        }
    }
}
