//
//  AppDelegate.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/23/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var toastViewBottom: NSLayoutConstraint!
    private var toastView: ToastView!
    private var subsideryWebViewContainer: UIView!


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let rootContainerViewController = RootViewController(rootViewControllerDelegate: self)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = rootContainerViewController
        self.window?.makeKeyAndVisible()
        
        setupToastView(window: window!)
        setupSubsideryWebViewContainer(window: window!)
        
        rootContainerViewController.webViewContainer = subsideryWebViewContainer
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.barTintColor = UIColor(rgb: 0x894DEB)
        navigationBarAppearace.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        setupAnalytics(application: application, launchOptions: launchOptions)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        SharedNote.shared.save()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)

        return handled
    }
}

extension AppDelegate {
    private func setupAnalytics(application: UIApplication, launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate: RootViewControllerDelegate {
    private func setupSubsideryWebViewContainer(window: UIWindow) {
        subsideryWebViewContainer = UIView(frame: .zero)
        subsideryWebViewContainer.backgroundColor = UIColor.clear
        subsideryWebViewContainer.translatesAutoresizingMaskIntoConstraints = false
        window.addSubview(subsideryWebViewContainer)
        
        window.leftAnchor.constraint(equalTo: subsideryWebViewContainer.leftAnchor, constant: 0).isActive = true
        window.rightAnchor.constraint(equalTo: subsideryWebViewContainer.rightAnchor, constant: 0).isActive = true
        window.bottomAnchor.constraint(equalTo: subsideryWebViewContainer.bottomAnchor, constant: 0).isActive = true
        subsideryWebViewContainer.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    private func setupToastView(window: UIWindow) {
        if let tv = Bundle.main.loadNibNamed("ToastView", owner: self, options: nil)?.first as? ToastView {
            toastView = tv
            toastView.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(toastView)
            
            
            toastViewBottom = window.bottomAnchor.constraint(equalTo: toastView.bottomAnchor, constant: -110)
            
            window.leftAnchor.constraint(equalTo: toastView.leftAnchor, constant: -15).isActive = true
            window.rightAnchor.constraint(equalTo: toastView.rightAnchor, constant: 15).isActive = true
            toastViewBottom.isActive = true
        }
    }
    
    func showToats(duration: TimeInterval = 4, style: AlertViewController.AlertViewControllerStyle) {
        showToast(style: style, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + duration) {
            self.hideToast(animated: true)
        }
    }
    
    private func showToast(style: AlertViewController.AlertViewControllerStyle, animated: Bool) {
        toastViewBottom.constant = 60
        switch style {
        case .error(let txt):
            self.toastView.toastViewLabel.text = txt
            self.toastView.toastViewImg.image = #imageLiteral(resourceName: "fail_alerticon")
        case .message(msg: let msg, onDismiss: let completion):
            self.toastView.toastViewLabel.text = msg
            self.toastView.toastViewImg.image = #imageLiteral(resourceName: "success_alerticon")
            completion()
        }
        
        UIView.animate(withDuration: animated ? 0.5 : 0.0) {
            self.toastView.superview?.layoutIfNeeded()
        }
    }
    
    private func hideToast(animated: Bool) {
        toastViewBottom.constant = -110
        
        UIView.animate(withDuration: animated ? 0.5 : 0.0, animations: {
            self.toastView.superview?.layoutIfNeeded()
        }) { _ in
            //self.toastView.toastViewLabel.text = ""
        }
    }
}

