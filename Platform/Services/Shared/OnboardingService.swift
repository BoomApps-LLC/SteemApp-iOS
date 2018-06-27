//
//  OnboardingService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 3/21/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public protocol OnboardingService {
    func skipedWifQ(completion: @escaping (Result<Bool?>) ->Void)
    func skipWif(completion: @escaping (Result<Bool>) ->Void)
    
    func skipedQrQ(completion: @escaping (Result<Bool?>) ->Void)
    func skipQr(completion: @escaping (Result<Bool>) ->Void)
}

public struct SteemOnboardingService {
    private let userDefaultsStorageService = UserDefaultsStorageService()
}

extension SteemOnboardingService: OnboardingService {
    public func skipedWifQ(completion: @escaping (Result<Bool?>) ->Void) {
        userDefaultsStorageService.get(key: Config.Storage.Keys.onboadingWifSkip, completion: completion)
    }
    
    public func skipWif(completion: @escaping (Result<Bool>) ->Void) {
        userDefaultsStorageService.save(value: true, key: Config.Storage.Keys.onboadingWifSkip, completion: completion)
    }
    
    public func skipedQrQ(completion: @escaping (Result<Bool?>) ->Void) {
        userDefaultsStorageService.get(key: Config.Storage.Keys.onboadingQrSkip, completion: completion)
    }
    
    public func skipQr(completion: @escaping (Result<Bool>) ->Void) {
        userDefaultsStorageService.save(value: true, key: Config.Storage.Keys.onboadingQrSkip, completion: completion)
    }
}
