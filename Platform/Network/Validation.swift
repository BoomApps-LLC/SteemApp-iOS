//
//  Validation.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Moya
import Alamofire

enum ResponseValidationError: Error {
    case invalidStatusCode
}

struct ValidStatusCodes {
    static var standart = { (request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult in
        let validStatusCodes = Array(200...299)
        
        if validStatusCodes.contains(response.statusCode) {
            return .success
        }
        
        return .failure(ResponseValidationError.invalidStatusCode)
    }
}


protocol Validatable {
    var validations: [DataRequest.Validation] { get }
}

struct MoyaValidationPlugin {
    
}

extension MoyaValidationPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        if let request = request as? DataRequest, let target = target as? Validatable {
            target.validations.forEach({ validation in
                request.validate(validation)
            })
        }
    }
}
