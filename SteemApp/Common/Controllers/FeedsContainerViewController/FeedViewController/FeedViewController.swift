//
//  FeedViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 5/15/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform
import Down
import SwiftSoup

protocol FeedViewControllerDelegate: class {
    func vote(feedViewController: FeedViewController, permlink: String, author: String, completion: @escaping (Bool) -> ())
}

class FeedViewController: UIViewController, Page {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomActivityContainerView: UIView!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var maintanceView: UIView!
    @IBOutlet weak var maintanceLabel: UILabel!
    
    internal var identifier: String
    
    private let refreshControl = UIRefreshControl()
    private var items: [Post] = []
    private var bodies: [String] = []
    private var accounts: [String: Account] = [:]
    private var postRewardCache: PostReward? = nil
    private var processingQ: Bool = false
    private var endfeedQ: Bool = false
    private var username: String
    
    private weak var delegate: FeedViewControllerDelegate?
    private weak var interfaceCoordinator: InterfaceCoordinator?
    private let userService = ServiceLocator.Application.userService()
    
    init(username: String, identifier: String, interfaceCoordinator: InterfaceCoordinator?, delegate: FeedViewControllerDelegate) {
        self.identifier = identifier
        self.interfaceCoordinator = interfaceCoordinator
        self.delegate = delegate
        self.username = username
        super.init(nibName: "FeedViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
    
        let nib = UINib(nibName: "FeedViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "FeedViewCellIdentifier")
        
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_ :)), for: .valueChanged)
        refreshControl.tintColor = UIColor.white
        activityIndicatorView.isHidden = true
        
        reloadFeed(completion: { err in
            self.showMaintanceScreenIfNeed(error: err)
        })
        reloadRewards(completion: {})
    }
    
    private func reloadFeed(completion: @escaping (Error?) -> ()) {
        let fs = ServiceLocator.Application.feedService()
        let ft = FeedTypes(rawValue: identifier)!
        
        progressView.appearAnimate(completion: { })
        fs.feed(type: ft, next: nil, completion: { (result: Result<[Post]>) in
            switch result {
            case .success(let posts):
                self.items = posts
                self.bodies = posts.map(self.plainifyBody)
                
                self.loadProfiles(completion: {
                    // TODO: need subtle update approch
                    self.collectionView.reloadData()
                })
                self.collectionView.reloadData()
                completion(nil)
                
                self.progressView.disappearAnimate(completion: { })
                break
            case .error(let err):
                self.interfaceCoordinator?.alert(presenter: self, style: .error("Something went wrong"))
                completion(err)
                
                self.progressView.disappearAnimate(completion: { })
                break
            }
        })
    }
    
    private func reloadRewards(completion: @escaping () -> ()) {
        let fs = ServiceLocator.Application.feedService()
        
        fs.postReward { (res: Result<PostReward>) in
            switch res {
            case .success(let postRewards):
                self.postRewardCache = postRewards
                break
            case .error:
                self.interfaceCoordinator?.alert(presenter: self, style: .error("Post rewards can't be calculate"))
                break
            }
            
            completion()
        }
    }
    
    private func plainifyBody(post: Post) -> String {
        do {
            let html = convertMarkdownToHtml(txt: post.body)
            let doc: Document = try SwiftSoup.parse(html)
            let linkedTxt = try doc.text()
            let txt = removeLink(txt: linkedTxt)
            
            return try txt.replacing(pattern: "^ ", with: "")
        } catch {
            return ""
        }
    }
    
    private func convertMarkdownToHtml(txt: String) -> String {
        let body = txt
            .replacingOccurrences(of: "<", with: "23bc876f-9322-4601-8be7-4cf660a0d33f")
            .replacingOccurrences(of: ">", with: "76beeec0-6ff2-4561-b737-4a1207b6b5ce")
        
        let down = Down(markdownString: body)
        var htmlBody = try! down.toHTML(DownOptions.safe) //????
        
        htmlBody = htmlBody
            .replacingOccurrences(of: "23bc876f-9322-4601-8be7-4cf660a0d33f", with: "<")
            .replacingOccurrences(of: "76beeec0-6ff2-4561-b737-4a1207b6b5ce", with: ">")
        
        return htmlBody
    }
    
    private func convertHtmlToPlainText(html: String) -> String {
        let htmlStringData = html.data(using: .utf8)!
        let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [.documentType: NSAttributedString.DocumentType.html]
        let attributedHTMLString = try? NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
        
        return attributedHTMLString?.string ?? ""
    }
    
    private func removeLink(txt: String) -> String {
        var b = txt
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: b, options: [], range: NSRange(location: 0, length: b.utf16.count))
        
        for match in matches.reversed() {
            guard let range = Range.init(match.range, in: b) else { continue }
            b.removeSubrange(range)
        }
        
        return b
    }
    
    private func showMaintanceScreenIfNeed(error: Error?) {
        self.maintanceView.isHidden = self.items.count > 0
        self.maintanceLabel.text = (error == nil ? "Steem App are the easiest way to share your ideas with the worl" : "Something's wrong")
    }
    
    @IBAction func reloadContentAction(_ sender: Any) {
        reloadFeed { err in
            self.showMaintanceScreenIfNeed(error: err)
        }
    }
}

extension FeedViewController {
    @objc func pullToRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        reloadFeed(completion: { err in
            refreshControl.endRefreshing()
            self.showMaintanceScreenIfNeed(error: err)
        })
        
        reloadRewards(completion: {
            
        })
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cvc = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedViewCellIdentifier", for: indexPath) as! FeedViewCell
        let i = item(at: indexPath)
        let b = body(at: indexPath)
        
        cvc.configure(username: username, item: i, body: b, dataSource: self, delegate: self)
        
        return cvc
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == items.count - 1, let lastItem = items.last, processingQ == false, endfeedQ == false {
            // Show activity indicator
            processingQ = true
            bottomActivityContainerView.isHidden = false
            //collectionView.contentInset = UIEdgeInsetsMake(0, 0, 40, 0)
            
            let fs = ServiceLocator.Application.feedService()
            let addparams = (start_author: lastItem.author, start_permlink: lastItem.permlink)
            let ft = FeedTypes(rawValue: identifier)!
            
            fs.feed(type: ft, next: addparams, completion: { (result: Result<[Post]>) in
                switch result {
                case .success(let posts):
                    // Remove dobble showing last element
                    if posts.count > 1 {
                        if let fpl = posts.first?.permlink, lastItem.permlink == fpl {
                            let newItems = posts.dropFirst()
                            let newBodies = newItems.map(self.plainifyBody)
                            
                            self.items.append(contentsOf: newItems)
                            self.bodies.append(contentsOf: newBodies)
                        } else {
                            self.items.append(contentsOf: posts)
                            self.bodies.append(contentsOf: posts.map(self.plainifyBody))
                        }
                        
                        self.loadProfiles(completion: {
                            // TODO: need subtle update approch
                            self.collectionView.reloadData()
                        })
                        self.collectionView.reloadData()
                    } else {
                        self.endfeedQ = true
                    }
                    break
                case .error:
                    self.interfaceCoordinator?.alert(presenter: self, style: .error("Something went wrong"))
                    break
                }
                
                // Hide activity indicator
                self.processingQ = false
                self.bottomActivityContainerView.isHidden = true
                //self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            })
        }
    }
    
    private func reloadPost(type: FeedTypes, permlink: String, author: String, completion: @escaping (Result<Post>) -> ()) {
        let fs = ServiceLocator.Application.feedService()
        fs.post(type: type, author: author, permlink: permlink, completion: completion)
    }
    
    private func loadProfiles(completion: @escaping () -> ()) {
        let authors = Array(Set(self.items.map({ $0.author })))
        userService.accounts(with: authors) { (res: Result<[Account]>) in
            if case Result<[Account]>.success(let accounts) = res {
                accounts.forEach({ account in
                    self.accounts[account.name] = account
                })
                
                // TODO here!
                //completion(accounts[author]?.profile_image, accounts[author]?.reputation)
            }
            
            completion()
        }
    }
}

extension FeedViewController: FeedViewCellDelegate {
    func showActivityIndicator() {
        activityIndicatorView.isHidden = false
    }
    
    func hideActivityIndicator() {
        activityIndicatorView.isHidden = true
    }
    
    func vote(feedViewCell: FeedViewCell, permlink: String, author: String, completion: @escaping (Bool) -> ()) {
        self.delegate?.vote(feedViewController: self, permlink: permlink, author: author, completion: { sccs in
            if sccs {
                let ft = FeedTypes(rawValue: self.identifier)!
                self.reloadPost(type: ft, permlink: permlink, author: author, completion: { res in
                    switch res {
                    case .success(let post):
                        if let idx = self.items.index(where: { ($0.author == author && $0.permlink == permlink) }) {
                            self.items[idx] = post
                            self.collectionView.reloadData()
                        }
                        
                        completion(true)
                    case .error:
                        completion(false)
                    }
                })
            } else {
                completion(false)
            }
        })
    }
}

extension FeedViewController: FeedViewCellDataSource {
    var postRewards: PostReward? {
        return postRewardCache
    }
    
    func account(author: String) -> Account? {
        return accounts[author]
    }
}

extension FeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let i = item(at: indexPath)
        let c = PostDetailsViewController(username: username, item: i, dataSource: self, delegate: self, interfaceCoordinator: interfaceCoordinator)
        
        present(c, animated: true, completion: nil)
    }
}

extension FeedViewController: PostDetailsViewControllerDelegate {
    func vote(postDetailsViewController: PostDetailsViewController, permlink: String, author: String, completion: @escaping (Bool) -> ()) {
        delegate?.vote(feedViewController: self, permlink: permlink, author: author, completion: completion)
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let i = item(at: indexPath)
        let b = body(at: indexPath)
        let height = FeedViewCell.height(item: i, body: b)
        return CGSize(width: collectionView.bounds.size.width - 20, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 40, right: 10)
    }
    
    private func item(at indexPath: IndexPath) -> Post {
        return items[indexPath.row]
    }
    
    private func body(at indexPath: IndexPath) -> String? {
        guard indexPath.row < bodies.count else { return nil }
        return bodies[indexPath.row]
    }
    
}
