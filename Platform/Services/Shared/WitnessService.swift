//
//  WitnessService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 4/3/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public protocol WitnessService {
    func increaseSuccessCount(completion: @escaping () -> ())
    func dontShowAgain(completion: @escaping () -> ())
    func witnessNeedShow(completion: @escaping (Bool) -> ())
}

struct SteemitWitnessService: WitnessService {
    let udss = UserDefaultsStorageService()
    
    public func increaseSuccessCount(completion: @escaping () -> ()) {
        udss.get(key: Config.Storage.Keys.postingSuccessCount) { (result: Result<Int?>) in
            switch result {
            case .success(let count):
                self.udss.save(value: (count ?? 0) + 1, key: Config.Storage.Keys.postingSuccessCount, completion: { _ in
                    completion()
                })
            case .error:
                self.udss.save(value: 1, key: Config.Storage.Keys.postingSuccessCount, completion: { _ in
                    completion()
                })
            }
        }
    }
    
    public func dontShowAgain(completion: @escaping () -> ()) {
        udss.save(value: false, key: Config.Storage.Keys.witnessNeedShowAgain, completion: { _ in
            completion()
        })
    }
    
    public func witnessNeedShow(completion: @escaping (Bool) -> ()) {
        udss.get(key: Config.Storage.Keys.witnessNeedShowAgain) { (result: Result<Bool?>) in
            switch result {
            case .success(let storageValue):
                if let needShow = storageValue, needShow == false {
                    completion(false)
                } else {
                    self.udss.get(key: Config.Storage.Keys.postingSuccessCount) { (result: Result<Int?>) in
                        switch result {
                        case .success(let someCount):
                            let count = (someCount ?? 1)
                            if count == 1 || count == 3 {
                                completion(true)
                            } else {
                                completion(false)
                            }
                        case .error:
                            completion(false)
                        }
                    }
                }
                
                
            case .error:
                completion(false)
            }
        }
    }
    
    
}
