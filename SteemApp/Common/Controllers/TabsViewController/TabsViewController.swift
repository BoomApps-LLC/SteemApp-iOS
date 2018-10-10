//
//  TabsViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 5/15/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import Foundation

class TabsViewController: UITabBarController {
    private var rootViewController: (UIViewController & InterfaceCoordinator)
    private var controllers: [UIViewController & Page]
    
    init(rootViewController: UIViewController & InterfaceCoordinator,
         controllers: [UIViewController & Page]) {
        self.rootViewController = rootViewController
        self.controllers = controllers
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.isHidden = true
    }
    
    private func reload() {
        let viewControllers: [UIViewController]
        
        if let startingViewController = self.viewController(atIndex: 0) {
            viewControllers = [startingViewController]
        } else {
            // TODO: Put empty VC
            viewControllers = [UIViewController()]
        }
        
        self.setViewControllers(viewControllers, animated: true)
    }
    
    func slideToPage(index: Int, completion: (() -> Void)?) {
        let count = self.controllers.count
        if index < count {
            if let vc = viewController(atIndex: index) {
                self.setViewControllers([vc], animated: true)
                completion?()
            }
        }
    }
    
    func setup(with containerController: UIViewController) {
        let pageView = self.view!
        
        reload()
        //self.delegate = self
        //self.dataSource = self
        
        //let startingViewController = self.viewController(atIndex: 0)!
        //let viewControllers = [startingViewController]
        //self.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        
        containerController.addChild(self)
        containerController.view.insertSubview(pageView, at: 0)
        pageView.flipToBorder()
        
        self.didMove(toParent: rootViewController)
    }
    
    private func viewController(atIndex index: Int) -> UIViewController? {
        // Return the data view controller for the given index.
        if (self.controllers.count == 0) || (index >= self.controllers.count) {
            return nil
        }
        
        return controllers[index]
    }
}
