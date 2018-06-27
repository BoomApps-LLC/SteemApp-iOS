//
//  InterfaceFlowPresentable.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/24/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import UIKit

protocol InterfaceFlowPresentable {
    func presentLoginInterface(inside window: UIWindow?)
    func presentMainInterface(inside window: UIWindow?)
}
