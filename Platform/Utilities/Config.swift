//
//  Config.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

public struct Config {
    struct Formatters {
        struct Date {
            static var standart: DateFormatter {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                return dateFormatter
            }
        }
    }
    
    struct Endpoints {
        struct Feed {
            static var url: URL {
                return URL(string: "https://api.steemit.com")!
            }
        }
        
        struct Login {
            static var url: URL {
                return URL(string: "https://api.steemit.com")!
            }
        }
        
        struct Wallet {
            static var helloacmUrl: URL {
                return URL(string: "https://helloacm.com/api/steemit/converter/")!
            }
            
            static var coinmarketcapUrlSBD2USD: URL {
                return URL(string: "https://api.coinmarketcap.com/v1/ticker/steem-dollars/")!
            }
            
            static var coinmarketcapUrlSTEEM2USD: URL {
                return URL(string: "https://api.coinmarketcap.com/v1/ticker/steem/")!
            }
        }
    }
    
    public struct API {
        struct Broadcast {
            static let rpcHandlerFilename = "rpchandler"
        }
        
        struct Chains {
            static let broadcastServiceChain = "broadcastServiceChain"
            static let authServiceChain = "authServiceChain"
            static let generalChain = "generalChain"
            static let signChain = "signChain"
        }
        
        public struct Messages {
            public static let startActivityIndicator = "startActivityIndicator"
            public static let stopActivityIndicator = "stopActivityIndicator"
            public static let noInternetConnection = "noInternetConnection"
            public static let invalidWif = "invalidWif"
            public static let validWifPaar = "validWifPaar"
            public static let invalidWifPaar = "invalidWifPaar"
            
            public static let postedSuccessfully = "postedSuccessfully"
        }
    }
    
    struct Storage {
        struct Keys {
            static let credentials = "com.steemit.credentials"
            static let balance = "com.steemit.balance"
            static let account = "com.steemit.account"
            static let sharednote = "com.steemit.sharednote"
            static let onboadingWifSkip = "com.steemit.onboarding4WIFskip"
            static let onboadingQrSkip = "com.steemit.onboarding4QRskip"
            static let onboadingDone = "com.steemit.onboardingdone"
            static let postingSuccessCount = "com.steemit.postingsuccesscount"
            static let witnessNeedShowAgain = "com.steemit.witnessDontShowAgain"
        }
    }
}

extension JSONDecoder {
    convenience init(formatter: DateFormatter) {
        self.init()
        self.dateDecodingStrategy = .formatted(formatter)
    }
}

extension JSONEncoder {
    convenience init(formatter: DateFormatter) {
        self.init()
        self.dateEncodingStrategy = .formatted(formatter)
    }
}
