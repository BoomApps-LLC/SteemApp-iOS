//
//  FeedsContainerViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/25/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform

class FeedsContainerViewController: UIViewController, Page {
    @IBOutlet weak var categoriesScrollView: UIScrollView!
    @IBOutlet weak var blogItem: UIButton!
    @IBOutlet weak var feedItem: UIButton!
    @IBOutlet weak var trendingItem: UIButton!
    @IBOutlet weak var newItem: UIButton!
    @IBOutlet weak var hotItem: UIButton!
    @IBOutlet weak var promotedItem: UIButton!
    @IBOutlet weak var pagesContainerView: UIView!
    
    private var broadcastSvc: (BroadcastService & UploadService)?
    private let userSvc = ServiceLocator.Application.userService()
    private var pagesViewController: PagesViewController!
    private let webViewContainer: UIView
    
    var all: [UIButton] {
        return [blogItem, feedItem, trendingItem, newItem, hotItem, promotedItem]
    }
    
    internal var identifier: String
    
    private weak var interfaceCoordinator: InterfaceCoordinator?
    private var source: UIViewController
    private let userService = ServiceLocator.Application.userService()
    
    init(identifier: String, interfaceCoordinator: InterfaceCoordinator?, source: UIViewController, webViewContainer: UIView) {
        self.source = source
        self.identifier = identifier
        self.interfaceCoordinator = interfaceCoordinator
        self.webViewContainer = webViewContainer
        super.init(nibName: "FeedsContainerViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blogItem.setTitle(FeedTypes.blog.rawValue, for: .normal)
        feedItem.setTitle(FeedTypes.feed.rawValue, for: .normal)
        trendingItem.setTitle(FeedTypes.trending.rawValue, for: .normal)
        newItem.setTitle(FeedTypes.new.rawValue, for: .normal)
        hotItem.setTitle(FeedTypes.hot.rawValue, for: .normal)
        promotedItem.setTitle(FeedTypes.promoted.rawValue, for: .normal)
        
        userSvc.logedQ { result in
            switch result {
            case .success(let someCreds):
                if case .some(let creds) = someCreds {
                    DispatchQueue.main.async {
                        let blogvc = FeedViewController(username: creds.username, identifier: self.identifier(at: 0), interfaceCoordinator: self.interfaceCoordinator, delegate: self)
                        let feedvc = FeedViewController(username: creds.username, identifier: self.identifier(at: 1), interfaceCoordinator: self.interfaceCoordinator, delegate: self)
                        let trendingvc = FeedViewController(username: creds.username, identifier: self.identifier(at: 2), interfaceCoordinator: self.interfaceCoordinator, delegate: self)
                        let createdvc = FeedViewController(username: creds.username, identifier: self.identifier(at: 3), interfaceCoordinator: self.interfaceCoordinator, delegate: self)
                        let hotvc = FeedViewController(username: creds.username, identifier: self.identifier(at: 4), interfaceCoordinator: self.interfaceCoordinator, delegate: self)
                        let promotedvc = FeedViewController(username: creds.username, identifier: self.identifier(at: 5), interfaceCoordinator: self.interfaceCoordinator, delegate: self)
                        
                        self.pagesViewController = PagesViewController(source: self, controllers: [blogvc, feedvc, trendingvc, createdvc, hotvc, promotedvc])
                        
                        self.addChild(self.pagesViewController)
                        self.pagesContainerView.addSubview(self.pagesViewController.view)
                        self.pagesViewController.view.flipToBorder()
                        
                        self.pagesViewController.didMove(toParent: self)
                        
                        //categoriesScrollView.contentSize = CGSize(width: 700, height: 55)
                        self.categoriesScrollView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                        self.categoriesScrollView.contentOffset = CGPoint(x: -20, y: 0)
                        
                        let startItem = self.identifier(at: 0)
                        self.highlightAndSeekCategory(title: startItem)
                        
                        self.broadcastSvc = ServiceLocator.Application.broadcastService(webViewConatiner: self.webViewContainer)
                    }
                    
                } else {
                    self.interfaceCoordinator?.alert(presenter: self, style: .error("Credentials can't be fetched"))
                }
            case .error:
                self.interfaceCoordinator?.alert(presenter: self, style: .error("Credentials can't be fetched"))
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    func highlightCategory(title: String) {
        all.enumerated().forEach { (idx, but) in
            if title == but.title(for: .normal) {
                but.alpha = 1.0
                self.categoriesScrollView.scrollRectToVisible(but.frame, animated: true)
            } else {
                but.alpha = 0.5
            }
        }
    }
    
    private func highlightAndSeekCategory(title: String) {
        all.enumerated().forEach { (idx, but) in
            if title == but.title(for: .normal) {
                seek(to: idx, completion: {
                    but.alpha = 1.0
                })
            } else {
                but.alpha = 0.5
            }
        }
    }
    
    private func identifier(at index: Int) -> String {
        let b = all[index]
        return b.title(for: .normal)!
    }
    
    private func seek(to index: Int, completion: (() -> ())?) {
        pagesViewController.slideToPage(index: index, completion: completion)
    }
    
    @IBAction func ItemAction(_ sender: UIButton) {
        highlightAndSeekCategory(title: sender.title(for: .normal)!)
    }
}

extension FeedsContainerViewController: FeedViewControllerDelegate {
    func vote(feedViewController: FeedViewController, permlink: String, author: String, completion: @escaping (Bool) -> ()) {
        userSvc.logedQ { result in
            switch result {
            case .success(let someCreds):
                if case .some(let creds) = someCreds {
                    let vote = BroadcastVote(voter: creds.username, author: author, permlink: permlink, weight: 10000)
                    self.broadcastSvc?.broadcastVote(wif: creds.postingKey, vote: vote, completion: { (res) in
                        switch res {
                        case .success(let sccflQ):
                            completion(sccflQ)
                            break
                        case .error:
                            completion(false)
                            self.interfaceCoordinator?.alert(presenter: self, style: .error("Something went wrong"))
                        }
                    })
                    
                } else {
                    completion(false)
                    self.interfaceCoordinator?.alert(presenter: self, style: .error("Credentials can't be fetched"))
                }
            case .error:
                completion(false)
                self.interfaceCoordinator?.alert(presenter: self, style: .error("Credentials can't be fetched"))
            }
        }
    }
}
