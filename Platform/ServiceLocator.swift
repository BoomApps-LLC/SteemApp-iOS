//
//  ServiceLocator.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import WebKit

public struct ServiceLocator {
    public struct Application {
        public static func userService() -> UserService {
            return SteemitUserService()
        }
        
        public static func broadcastService(webViewConatiner: UIView) -> (BroadcastService & UploadService) {
            return SteemitBroadcastService(webViewConatiner: webViewConatiner)
        }
        
        public static func authService(webViewConatiner: UIView) -> AuthService {
            return SteemitBroadcastService(webViewConatiner: webViewConatiner)
        }
        
        public static func walletService() -> WalletService {
            return SteemitWalletService()
        }
        
        public static func noteService() -> NoteService {
            return SteemitNoteService()
        }
        
        public static func reachabilityService() -> ReachabilityService {
            return ApplicationReachabilitySvc()
        }
        
        public static func onboardingService() -> OnboardingService {
            return SteemOnboardingService()
        }
        
        public static func witnessService() -> WitnessService {
            return SteemitWitnessService()
        }
        
        public static func feedService() -> FeedService {
            return SteemitFeedService()
        }
    }
}
