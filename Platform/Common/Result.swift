//
//  Result.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/25/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T), error(Error)
    
    init(value: T) {
        self = Result<T>.success(value)
    }
    
    init(error: Error) {
        self = Result<T>.error(error)
    }
    
    func flatMap<A>(transform: (Result<T>) -> Result<A>) -> Result<A> {
        return transform(self)
    }
    
    func errorTransform<A>(srcResult: Result<T>) -> Result<A> {
        switch srcResult {
        case .success:
            fatalError("Only for error")
        case .error(let e):
            return Result<A>.error(e)
        }
    }
    
    func map<A>(transform: (Result<T>) -> Result<A>) -> Result<A> {
        return transform(self)
    }
    
    public func bimap(onSuccess: (T) -> (), onError: (Error) -> ()) {
        switch self {
        case .success(let obj):
            onSuccess(obj)
        case .error(let err):
            onError(err)
        }
    }
}
