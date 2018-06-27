//
//  UIView+Ext.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/25/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit


extension UIView {
    func flipToBorder(_ leading: CGFloat = 0, _ trailing: CGFloat = 0, _ top: CGFloat = 0, _ bottom: CGFloat = 0) {
        guard let sv = superview else {return}
        
        leftAnchor.constraint(equalTo: sv.leftAnchor, constant: leading).isActive = true
        rightAnchor.constraint(equalTo: sv.rightAnchor, constant: trailing).isActive = true
        topAnchor.constraint(equalTo: sv.topAnchor, constant: top).isActive = true
        bottomAnchor.constraint(equalTo: sv.bottomAnchor, constant: bottom).isActive = true
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func addBorder(witdh: CGFloat = 1, color: UIColor = UIColor.red) {
        layer.borderColor = color.cgColor
        layer.borderWidth = witdh
    }
}

extension UIColor {
    convenience init(rgb: Int32) {
        self.init(red: CGFloat((rgb >> 16) & 0xFF) / 255,
                  green: CGFloat((rgb >> 8) & 0xFF) / 255.0,
                  blue: CGFloat(rgb & 0xff) / 255.0,
                  alpha: 1)
    }
}

extension UIViewController {
    
    /// Returns the current application's top most view controller.
    open class var topMost: UIViewController? {
        var rootViewController: UIViewController?
        let currentWindows = UIApplication.shared.windows
        
        for window in currentWindows {
            if let windowRootViewController = window.rootViewController {
                rootViewController = windowRootViewController
                break
            }
        }
        
        return self.topMost(of: rootViewController)
    }
    
    /// Returns the top most view controller from given view controller's stack.
    open class func topMost(of viewController: UIViewController?) -> UIViewController? {
        // presented view controller
        if let presentedViewController = viewController?.presentedViewController {
            return self.topMost(of: presentedViewController)
        }
        
        // UITabBarController
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return self.topMost(of: selectedViewController)
        }
        
        // UINavigationController
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return self.topMost(of: visibleViewController)
        }
        
        // UIPageController
        if let pageViewController = viewController as? UIPageViewController,
            pageViewController.viewControllers?.count == 1 {
            return self.topMost(of: pageViewController.viewControllers?.first)
        }
        
        // child view controller
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return self.topMost(of: childViewController)
            }
        }
        
        return viewController
    }
    
}
