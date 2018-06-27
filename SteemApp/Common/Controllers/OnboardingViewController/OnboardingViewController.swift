//
//  OnboardingViewController.swift
//  TestPages
//
//  Created by Siarhei Suliukou on 3/21/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform

class OnboardingViewController: UIViewController, UIPageViewControllerDelegate {
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var onboardingShowingContentType: OnboardingShowingContentType = .wif
    var onclose: (() -> ())?
    private let onboardingSvc = ServiceLocator.Application.onboardingService()
    
    var pageViewController: UIPageViewController?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self

        let startingViewController: OnboardingDataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })

        self.pageViewController!.dataSource = self.modelController

        self.addChildViewController(self.pageViewController!)
        self.view.insertSubview(self.pageViewController!.view, at: 0)
        self.pageViewController!.view.flipToBorder()
        self.pageViewController!.didMove(toParentViewController: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func skipAction(_ sender: Any) {
        switch onboardingShowingContentType {
        case .wif:
            onboardingSvc.skipWif { _ in
                self.dismiss(animated: true, completion: self.onclose)
            }
        case .qr:
            onboardingSvc.skipQr { _ in
                self.dismiss(animated: true, completion: self.onclose)
            }
        }
        
        
    }
    
    @IBAction func nextAction(_ sender: Any) {
        // Done button
        if self.nextButton.isSelected == true {
            skipAction(nextButton)
            return
        }
        
        if let cvc = pageViewController?.viewControllers?.first as? OnboardingDataViewController,
            let currentIdx = cvc.onboardingData?.index,
            currentIdx + 1 < modelController.pageData.count {
            let nextIdx = currentIdx + 1
            slideToPage(index: nextIdx) {
                self.nextButton.isSelected = (nextIdx == self.modelController.pageData.count - 1)
            }
        }
    }
    
    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController(showingContentType: onboardingShowingContentType)
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

            self.pageViewController!.isDoubleSided = false
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! OnboardingDataViewController
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

        return .mid
    }

    
    func slideToPage(index: Int, completion: (() -> Void)?) {
        if let vc = self.modelController.viewControllerAtIndex(index, storyboard: self.storyboard!) {
            let direction: UIPageViewControllerNavigationDirection = .forward
            self.pageViewController?.setViewControllers([vc], direction: direction, animated: true, completion: { (complete) -> Void in
                completion?()
            })
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating
        finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
            let vc = pageViewController.viewControllers?.first as? OnboardingDataViewController,
            let nextIdx = vc.onboardingData?.index {
            
            self.nextButton.isSelected = (nextIdx == self.modelController.pageData.count - 1)
        }
    }
}

