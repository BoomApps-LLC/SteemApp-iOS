//
//  PagesViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 2/26/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

protocol Page {
    var identifier: String { get }
}

final class PagesViewController: UIPageViewController {
    private(set) var source: UIViewController
    private var controllers: [UIViewController & Page]
    
    init(source: UIViewController, controllers: [UIViewController & Page]) {
        self.source = source
        self.controllers = controllers
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        let startingViewController = self.viewController(atIndex: 0)!
        let viewControllers = [startingViewController]
        self.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
    }
}

extension PagesViewController: UIPageViewControllerDelegate {
}

extension PagesViewController: UIPageViewControllerDataSource {
    func viewController(atIndex index: Int) -> UIViewController? {
        // Return the data view controller for the given index.
        if (self.controllers.count == 0) || (index >= self.controllers.count) {
            return nil
        }
        
        return controllers[index]
    }
    
    func indexOfViewController(_ viewController: Page) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return controllers.map({ $0.identifier }).index(of: viewController.identifier) ?? NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating
        finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let vc = viewControllers?.first as? Page, let pvc = parent as? FeedsContainerViewController {
            pvc.highlightCategory(title: vc.identifier)
        }
    }
    
    func slideToPage(index: Int, completion: (() -> Void)?) {
        let count = self.controllers.count
        if index < count, let cvc = viewControllers?.first as? Page {
            if let vc = viewController(atIndex: index) {
                let currentIndex = indexOfViewController(cvc)
                let direction: UIPageViewController.NavigationDirection = (index > currentIndex ? .forward : .reverse )
                self.setViewControllers([vc], direction: direction, animated: true, completion: { (complete) -> Void in
                    completion?()
                })
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! Page)
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewController(atIndex: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! Page)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        
        if index == self.controllers.count {
            return nil
        }
        return self.viewController(atIndex: index)
    }
    
}

