//
//  UserDefaultsStorageService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 3/6/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public enum UserDefaultsStorageServiceError: Error {
    case underline(Error)
}

fileprivate struct Constants {
    static var queueLabel: String {
        return "com.storage.userDefaultsStorage"
    }
}

struct UserDefaultsStorageService: StorageService {
    private let userDefaults = UserDefaults.standard
    private static let queue = DispatchQueue(label: Constants.queueLabel, attributes: .concurrent)
    
    private struct Box<T: Codable>: Codable {
        let some: T
    }
    
    func save<T: Codable>(value: T, key: String, completion: @escaping (Result<T>) -> ()) {
        type(of: self).queue.async(flags: .barrier) {
            do {
                let preparedObject = Box<T?>(some: value)
                let jsonEncoder = JSONEncoder(formatter: Config.Formatters.Date.standart)
                let jsonData = try jsonEncoder.encode(preparedObject)
                self.userDefaults.set(jsonData, forKey: key)
                
                DispatchQueue.main.async {
                    let result = Result<T>(value: value)
                    completion(result)
                }
            } catch let error {
                let castedError = UserDefaultsStorageServiceError.underline(error)
                DispatchQueue.main.async {
                    let result = Result<T>(error: castedError)
                    completion(result)
                }
            }
        }
    }
    
    func delete<T: Codable>(key: String, completion: @escaping (Result<T?>) -> Void) {
        get(key: key, completion: { (result: Result<T?>) in
            switch result {
            case .success(let object):
                type(of: self).queue.async(flags: .barrier) {
                    self.userDefaults.removeObject(forKey: key)
                    
                    DispatchQueue.main.async {
                        let result = Result<T?>(value: object)
                        completion(result)
                    }
                }
            case .error(let error):
                let castedError = UserDefaultsStorageServiceError.underline(error)
                DispatchQueue.main.async {
                    let result = Result<T?>(error: castedError)
                    completion(result)
                }
            }
        })
    }
    
    func get<T: Codable>(key: String, completion: @escaping (Result<T?>) -> Void) {
        type(of: self).queue.sync {
            do {
                guard let decodedData = self.userDefaults.data(forKey: key) else {
                    DispatchQueue.main.async {
                        let result = Result<T?>(value: nil)
                        completion(result)
                    }
                    return
                }
                
                let jsonDecoder = JSONDecoder(formatter: Config.Formatters.Date.standart)
                let object = try jsonDecoder.decode(Box<T?>.self, from: decodedData)
                DispatchQueue.main.async {
                    let result = Result<T?>(value: object.some)
                    completion(result)
                }
            } catch let error {
                let castedError = UserDefaultsStorageServiceError.underline(error)
                DispatchQueue.main.async {
                    let result = Result<T?>(error: castedError)
                    completion(result)
                }
            }
        }
    }
}
