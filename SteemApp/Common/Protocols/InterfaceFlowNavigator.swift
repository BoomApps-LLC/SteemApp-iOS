//
//  InterfaceFlowNavigator.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/24/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation
import UIKit

protocol RootViewControllerDelegate: class {
    func showToats(duration: TimeInterval, style: AlertViewController.AlertViewControllerStyle)
}

protocol Navigatable {
    func dismiss(_ viewController: UIViewController, completion: (() -> ())?)
    func back(_ viewController: UIViewController)
    func cycle(from oldViewController: UIViewController, to newViewController: UIViewController)
}

protocol CoordinatorRespondable {
    var interfaceCoordinator: InterfaceCoordinator { get }
}

protocol InterfaceCoordinator: class, Navigatable {
    func onboarding(contentType: OnboardingShowingContentType, onclose: (() -> ())?)
    func logedIn()
    func logedOut()
    func newtitle()
    func newnote(_ previousViewController: UIViewController)
    func tags(_ previousViewController: UIViewController)
    func rewards(_ previousViewController: UIViewController)
    func alert(presenter viewController: UIViewController, style: AlertViewController.AlertViewControllerStyle)
    func witnessVote(presenter viewController: UIViewController, onClose: @escaping () -> (), onVote: @escaping () -> ())
    func signup()
    func vote(completion: @escaping () -> ())
    
    func showActivityIndicator(_ completion: (() -> Swift.Void)?)
    func hideActivityIndicator(_ completion: (() -> Swift.Void)?)
    
    func showPostingProgress(_ completion: (() -> Swift.Void)?)
    func hidePostingProgress(_ completion: (() -> Swift.Void)?)
    func updatePostingProgress(status: UploadProgressStatus)
    
    func highlightButton(at index: Int)
}
