//
//  ReachabilityService.swift
//  Platform
//
//  Created by Siarhei Suliukou on 1/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import SystemConfiguration
import Photos

public enum ReachabilitySvcError: Error {
    case noInternetConnection
}

public protocol ReachabilityService {
    static var internetConnectedQ: Bool { get }
    func photoAccess(onAuthorized: @escaping () -> (), onNonauthorised: @escaping () -> (), onRestricted: @escaping () -> (), onDenied: @escaping () -> () )
}

public struct ApplicationReachabilitySvc {
    
}

extension ApplicationReachabilitySvc: ReachabilityService {
    public static var internetConnectedQ: Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    public func photoAccess(onAuthorized: @escaping () -> (), onNonauthorised: @escaping () -> (), onRestricted: @escaping () -> (), onDenied: @escaping () -> () ) {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    onAuthorized()
                } else {
                    onNonauthorised()
                }
            })
        case .restricted:
            onRestricted()
        case .denied:
            onDenied()
        case .authorized:
            onAuthorized()
        }
    }
}
