//
//  RootContainerViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/25/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform

class RootViewController: UIViewController {
    @IBOutlet weak var feedButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    weak var delegate: RootViewControllerDelegate?
    
    private var tabsViewController: TabsViewController?
    
    init(rootViewControllerDelegate: RootViewControllerDelegate) {
        self.delegate = rootViewControllerDelegate
        super.init(nibName: "RootViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadInterface()
    }

    @IBAction func feedButtonAction(_ sender: Any) {
        tabsViewController?.slideToPage(index: 0, completion: {
            self.highlightButton(at: 0)
        })
    }
    
    @IBAction func postButtonAction(_ sender: Any) {
        self.newtitle()
    }
    
    @IBAction func profileButtonAction(_ sender: Any) {
        tabsViewController?.slideToPage(index: 1, completion: {
            self.highlightButton(at: 1)
        })
    }
}

extension RootViewController: InterfaceCoordinator {
    func onboarding(contentType: OnboardingShowingContentType, onclose: (() -> ())?) {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        controller.onboardingShowingContentType = contentType
        controller.onclose = onclose
        self.present(controller, animated: true, completion: nil)
    }
    
    func showPostingProgress(_ completion: (() -> Void)?) {
        let uploadProgressViewController = UploadProgressViewController()
        uploadProgressViewController.modalPresentationStyle = .custom
        
        if let viewController = UIViewController.topMost, (viewController is UploadProgressViewController) == false {
            viewController.present(uploadProgressViewController, animated: false, completion: completion)
        } else {
            completion?()
        }
    }
    
    func hidePostingProgress(_ completion: (() -> Void)?) {
        let viewController = UIViewController.topMost
        
        if viewController is UploadProgressViewController {
            viewController?.dismiss(animated: false, completion: completion)
        } else {
            completion?()
        }
    }
    
    func updatePostingProgress(status: UploadProgressStatus) {
        if let viewController = UIViewController.topMost as? UploadProgressViewController {
            viewController.update(status: status)
        }
    }
    
    func highlightButton(at index: Int) {
        if index == 0 {
            self.feedButton.isSelected = true
            self.feedButton.alpha = 1.0
            self.profileButton.isSelected = false
            self.profileButton.alpha = 0.5
        } else if index == 1 {
            self.profileButton.isSelected = true
            self.profileButton.alpha = 1.0
            self.feedButton.isSelected = false
            self.feedButton.alpha = 0.5
        }
    }
    
    func logedOut() {
        if let topViewController = self.childViewControllers.last as? TabsViewController {
            let loginViewController = LoginViewController(interfaceCoordinator: self)
            self.cycle(from: topViewController, to: loginViewController)
            self.tabsViewController = nil
            setButtons(hidden: true)
        }
    }
    
    func logedIn() {
        if let topViewController = self.childViewControllers.last as? LoginViewController {
            configureTabsViewController()
            cycle(from: topViewController, to: self.tabsViewController!)
            tabsViewController?.setup(with: self)
            setButtons(hidden: false)
        }
    }
    
    func newtitle() {
        let titleViewController = TitleViewController(interfaceCoordinator: self)
        let navigationViewController = UINavigationController(rootViewController: titleViewController)
        
        titleViewController.modalPresentationStyle = .custom
        navigationViewController.setNavigationBarHidden(true, animated: false)
        navigationViewController.view.backgroundColor = UIColor(rgb: 0x894DEB)
        self.present(navigationViewController, animated: true, completion: {
            SharedNote.shared.get(onexists: { note in
                SharedNote.shared.create(with: note)
                titleViewController.set(sharedNote: SharedNote.shared)
            }, onabsent: {
                SharedNote.shared.create(with: nil)
                titleViewController.set(sharedNote: SharedNote.shared)
            })
        })
    }
    
    func newnote(_ previousViewController: UIViewController) {
        let noteTextViewController = NoteTextViewController(interfaceCoordinator: self)
        
        noteTextViewController.modalPresentationStyle = .custom
        previousViewController.navigationController?.pushViewController(noteTextViewController, animated: true)
    }
    
    func tags(_ previousViewController: UIViewController) {
        let tagsViewController = TagsViewController(interfaceCoordinator: self)
        
        tagsViewController.modalPresentationStyle = .custom
        previousViewController.navigationController?.pushViewController(tagsViewController, animated: true)
    }
    
    func rewards(_ previousViewController: UIViewController) {
        let rewardsViewController = RewardsViewController(interfaceCoordinator: self, note: SharedNote.shared)
        
        rewardsViewController.modalPresentationStyle = .custom
        previousViewController.navigationController?.pushViewController(rewardsViewController, animated: true)
    }
    
    func alert(presenter viewController: UIViewController, style: AlertViewController.AlertViewControllerStyle) {
        delegate?.showToats(duration: 3, style: style)
    }
    
    func witnessVote(presenter viewController: UIViewController, onClose: @escaping () -> (), onVote: @escaping () -> ()) {
        let witnessVoteViewController = WitnessVoteViewController(interfaceCoordinator: self, onClose: onClose, onVote: onVote)
        
        witnessVoteViewController.modalPresentationStyle = .custom
        viewController.present(witnessVoteViewController, animated: false, completion: nil)
    }
    
    func signup() {
        let wvc = WebContentViewController(urlString: "https://steemit.com/pick_account", prefferedTitle: "Sign Up")
        let nc = UINavigationController(rootViewController: wvc)
        
        self.present(nc, animated: true, completion: nil)
    }
    
    func vote(completion: @escaping () -> ()) {
        if let url = URL(string: "https://steemconnect.com/sign/account-witness-vote?witness=yuriks2000&approve=1") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    func showActivityIndicator(_ completion: (() -> Swift.Void)?) {
        let activityViewController = ActivityViewController(interfaceCoordinator: self)
        activityViewController.modalPresentationStyle = .custom
        
        if let viewController = UIViewController.topMost, (viewController is SteemApp.ActivityViewController) == false {
            viewController.present(activityViewController, animated: false, completion: completion)
        } else {
            completion?()
        }
    }
    
    func hideActivityIndicator(_ completion: (() -> Swift.Void)?) {
        let viewController = UIViewController.topMost
        
        if viewController is SteemApp.ActivityViewController {
            viewController?.dismiss(animated: false, completion: completion)
        } else {
            completion?()
        }
    }
}

extension RootViewController: Navigatable {
    func dismiss(_ viewController: UIViewController, completion: (() -> ())? = nil) {
        if viewController is UINavigationController {
            viewController.navigationController?.dismiss(animated: true, completion: completion)
        } else {
            viewController.dismiss(animated: true, completion: completion)
        }
    }
    
    func back(_ viewController: UIViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
    
    func cycle(from oldViewController: UIViewController, to newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        
        self.transition(from: oldViewController,
                        to: newViewController,
                        duration: 1.5,
                        options: UIViewAnimationOptions.allowAnimatedContent,
                        animations: {
                            
                            //self.view.layoutIfNeeded()
        }) { _ in
            newViewController.view.flipToBorder()
            oldViewController.removeFromParentViewController()
            newViewController.didMove(toParentViewController: self)
        }
    }
    
    private func removeViewController(_ viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}

extension RootViewController {
    func loadInterface() {
        let userService = ServiceLocator.Application.userService()
        userService.logedQ { result in
            switch result {
            case .success(let credentials):
                if credentials == nil {
                    self.loginInterfaceFlow()
                } else {
                    self.mainInterfaceFlow()
                }
            case .error:
                self.loginInterfaceFlow()
            }
        }
    }
    
    private func loginInterfaceFlow() {
        let loginViewController = LoginViewController(interfaceCoordinator: self)
        
        self.addChildViewController(loginViewController)
        self.view.addSubview(loginViewController.view)
        
        loginViewController.view.flipToBorder()
        loginViewController.didMove(toParentViewController: self)
        
        setButtons(hidden: true)
    }
    
    private func mainInterfaceFlow() {
        configureTabsViewController()
        tabsViewController?.setup(with: self)
        
        setButtons(hidden: false)
    }
    
    private func configureTabsViewController() {
        let walletViewController = FeedsContainerViewController(identifier: "feed", interfaceCoordinator: self, source: self)
        let profileViewController = ProfileViewController(identifier: "profile", interfaceCoordinator: self)
        let controllers = [walletViewController, profileViewController] as! [UIViewController & Page]
        self.tabsViewController = TabsViewController(rootViewController: self, controllers: controllers)
        self.highlightButton(at: 0)
    }
    
    private func setButtons(hidden: Bool) {
        feedButton.isHidden = hidden
        postButton.isHidden = hidden
        profileButton.isHidden = hidden
    }
}
