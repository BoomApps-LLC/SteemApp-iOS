//
//  Serialization.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import Alamofire
import Moya

enum SerializerError: Error {
    case underline(SerializerErrorDescription)
    case parseError
}

protocol Serializable {
    var serializer: Parseble { get }
}

protocol Parseble {
    func parse<T: Codable>(responseData: Response) throws -> T
}

struct JSONBoxSerializer {
}

extension JSONBoxSerializer: Parseble {
    func parse<T: Codable>(responseData: Response) throws -> T {
        let jsonDecoder = JSONDecoder(formatter: Config.Formatters.Date.standart)
        do {
            let resultBox = try jsonDecoder.decode(ResultBox<T>.self, from: responseData.data)
            return resultBox.result
        } catch {
            let errorBox = try jsonDecoder.decode(ErrorBox.self, from: responseData.data)
            throw SerializerError.underline(errorBox.error)
        }
        
    }
}


struct JSONDataSerializer {
}

extension JSONDataSerializer: Parseble {
    func parse<T: Codable>(responseData: Response) throws -> T {
        let jsonDecoder = JSONDecoder(formatter: Config.Formatters.Date.standart)
        do {
            let result = try jsonDecoder.decode(T.self, from: responseData.data)
            return result
        } catch {
            throw SerializerError.parseError
        }
        
    }
}
