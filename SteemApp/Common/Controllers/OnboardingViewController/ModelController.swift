//
//  ModelController.swift
//  TestPages
//
//  Created by Siarhei Suliukou on 3/21/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */

enum OnboardingShowingContentType {
    case qr
    case wif
}

class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageData: [OnboardingData] = []
    private let onboardingShowingContentType: OnboardingShowingContentType


    init(showingContentType: OnboardingShowingContentType) {
        self.onboardingShowingContentType = showingContentType
        
        switch showingContentType {
        case .qr:
            let page1 = OnboardingData(index: 0, title: "A Quick Login Guide", subtitle: "Go to My wallet on Steemit.com", imageName: "onboarding_01")
            let page2 = OnboardingData(index: 1, title: "A Quick Login Guide", subtitle: "Then select Permissions Tab", imageName: "onboarding_02")
            let page3 = OnboardingData(index: 2, title: "A Quick Login Guide", subtitle: "Then select Permissions Tab", imageName: "onboarding_03")
            let page4 = OnboardingData(index: 3, title: "A Quick Login Guide", subtitle: "Private posting key begins with a 5", imageName: "onboarding_04")
            let page5 = OnboardingData(index: 4, title: "A Quick Login Guide", subtitle: "Tap Show Private Key", imageName: "onboarding_05")
            pageData = [page1, page2, page3, page4, page5]
        case .wif:
            let page1 = OnboardingData(index: 0, title: "A Quick Login Guide", subtitle: "Go to My wallet on Steemit.com", imageName: "onboarding_01")
            let page2 = OnboardingData(index: 1, title: "A Quick Login Guide", subtitle: "Then select Permissions Tab", imageName: "onboarding_02")
            let page3 = OnboardingData(index: 2, title: "A Quick Login Guide", subtitle: "Then select Permissions Tab", imageName: "onboarding_03")
            let page4 = OnboardingData(index: 3, title: "A Quick Login Guide", subtitle: "Private posting key begins with a 5", imageName: "onboarding_04")
            pageData = [page1, page2, page3, page4]
        }
        
        super.init()
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageData.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        let vc = pageViewController.viewControllers![0] as! OnboardingDataViewController
        return vc.onboardingData?.index ?? 0
    }

    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> OnboardingDataViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! OnboardingDataViewController
        dataViewController.onboardingData = self.pageData[index]
        return dataViewController
    }

    func indexOfViewController(_ viewController: OnboardingDataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        
        return viewController.onboardingData?.index ?? NSNotFound
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! OnboardingDataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! OnboardingDataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
}

