//
//  PostDetailsViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 5/15/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import WebKit
import Platform
import Down
import SwiftSoup

protocol PostDetailsViewControllerDelegate: class {
    func vote(postDetailsViewController: PostDetailsViewController, permlink: String, author: String, completion: @escaping (Bool) -> ())
}

class PostDetailsViewController: UIViewController {
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoUserNameLabel: UILabel!
    @IBOutlet weak var infoTimeLabel: UILabel!
    @IBOutlet weak var infoNetVotesButton: UIButton!
    @IBOutlet weak var infoChildrenButton: UIButton!
    @IBOutlet weak var infoRepliesButton: UIButton!
    @IBOutlet weak var infoTotalPayoutValueButton: UIButton!
    @IBOutlet weak var infoReputationLabel: UILabel!
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var navigationPanelView: UIView!
    @IBOutlet weak var navigationBarTopConstr: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIView!
    
    private var webView: WKWebView!
    private weak var interfaceCoordinator: InterfaceCoordinator?
    private weak var dataSource: FeedViewCellDataSource?
    private weak var delegate: PostDetailsViewControllerDelegate?
    
    private let item: Post
    private var prevContentOffsetY: CGFloat = 0
    private let username: String
    
    init(username: String, item: Post, dataSource: FeedViewCellDataSource,
         delegate: PostDetailsViewControllerDelegate, interfaceCoordinator: InterfaceCoordinator?) {
        self.item = item
        self.dataSource = dataSource
        self.delegate = delegate
        self.username = username
        self.interfaceCoordinator = interfaceCoordinator
        
        super.init(nibName: "PostDetailsViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webViewContainer.addSubview(webView)
        webView.flipToBorder()
        
        activityView.isHidden = true
        
        parse(item: item)
        updateInfoSection(with: item)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func infoTotalPayoutValueAction(_ sender: Any) {
        let permlink = item.permlink
        let author = item.author
        
        activityView.isHidden = false
        delegate?.vote(postDetailsViewController: self, permlink: permlink, author: author, completion: { sccfl in
            self.infoTotalPayoutValueButton.isSelected = sccfl
            self.activityView.isHidden = true
        })
    }
    
    private func updateInfoSection(with item: Post) {
        if let acc = dataSource?.account(author: item.author), let some_img = acc.profile_image, let img_url = URL(string: some_img) {
            self.infoImageView.kf.setImage(with: img_url)
            
            self.infoReputationLabel.text = String(format: "%0.0f", acc.reputation)
        }
        
        if let acc = dataSource?.account(author: item.author) {
            self.infoReputationLabel.text = String(format: "%0.0f", acc.reputation)
        }
        
        infoUserNameLabel.text = item.author
        
        infoTimeLabel.text = item.createdText
        infoNetVotesButton.setTitle("\(item.active_votes.count)", for: .normal)
        infoChildrenButton.setTitle("\(item.children)", for: .normal)
        infoRepliesButton.setTitle("\(item.replies.count)", for: .normal)
        infoTotalPayoutValueButton.isSelected = (item.active_votes.first(where: { av -> Bool in
            return av.voter == username
        }) != nil)
        
        let pv = item.total_payout_value.double + item.curator_payout_value.double
        
        if pv > 0 {
            infoTotalPayoutValueButton.setTitle(String(format: "%0.2f", pv), for: .normal)
        } else {
            var cost: Double = 0.0
            
            if let pr = self.dataSource?.postRewards {
                cost = item.active_votes.reduce(0, { (res, actVote) -> Double in
                    res + Double(actVote.rshares) * pr.reward_balance / pr.recent_claims * pr.base
                })
            }
            
            self.infoTotalPayoutValueButton.setTitle(String(format: "%0.2f", cost), for: .normal)
        }
    }
    
    private func parse(item: Post) {
        let body = item.body.removeBrackets
        let down = Down(markdownString: body)
        let noteBody = try! down.toHTML(DownOptions.safe)
        let htmlContent = "<H1>" + item.title + "</H1>" + noteBody.returnBrackets
        let brContent = htmlContent
            .replacingOccurrences(of: "\n", with: "<div style='height:2px;'><br></div>")
            .replacingOccurrences(of: "&quot;", with: "'")
            .replacingOccurrences(of: "\\ '", with: "\\'")
        
        let linkResolved = wrapImageLinks(txt: brContent)
        
        set(content: linkResolved)
    }
    
    private func set(content: String) {
        let stl = Bundle.main.path(forResource: "notestyle", ofType: "html")!
        let url = URL(fileURLWithPath: stl)
        
        if let dat = try? Data(contentsOf: url), let cntnt = String(data: dat, encoding: .utf8) {
            do {
                let doc: Document = try SwiftSoup.parse(cntnt)
                try doc.body()?.append(content)
                let html = try doc.html()
                
                self.webView.loadHTMLString(html, baseURL: Bundle.main.bundleURL)
            } catch {
                
            }
        }
    }
    
    private func wrapImageLinks(txt: String) -> String {
        // TODO: Remove force unwrap
        var b = txt
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: b, options: [], range: NSRange(location: 0, length: b.utf16.count))
        
        let linkWithQuoteAtTheEndOrYoutubeQ: (String) -> Bool = {lnk in
            let det = try? lnk.replacing(pattern: "(\"|\')$", with: "").replacing(pattern: "(youtube\\.com)|(youtu\\.be)", with: "")
            return (det ?? lnk).count < lnk.count
        }
        
        let imgLinkQ: (String) -> Bool = {lnk in
            return ((try? lnk.replacing(pattern: ".(?:jpg|gif|png)$", with: "")) ?? lnk).count < lnk.count
        }
        
        for match in matches.reversed() {
            let someRange = Range.init(match.range, in: b)!
            let someLink = String(b[someRange])
            let link = try! someLink.replacing(pattern: "<(\\S+)$", with: "").replacing(pattern: "(\"|\')(\\S+)$", with: "")
            let nsRange = NSRange.init(location: match.range.location, length: match.range.length - (someLink.count - link.count))
            let range = Range.init(nsRange, in: b)!
            let extNsRange = NSRange.init(location: match.range.location, length: match.range.length + 1 - (someLink.count - link.count))
            let extRange = Range.init(extNsRange, in: b)!
            let extendedLink = String(b[extRange])

            if linkWithQuoteAtTheEndOrYoutubeQ(extendedLink) == false {
                if imgLinkQ(link) == true {
                    b.replaceSubrange(range, with: "<img src=\'\(link)\'/>")
                } else {
                    b.replaceSubrange(range, with: "<a href=\'\(link)\'>\(link)</a>")
                }
            }
        }
        
        return b
    }
}

extension String {
    var removeBrackets: String {
        return self
            .replacingOccurrences(of: "<", with: "23bc876f-9322-4601-8be7-4cf660a0d33f")
            .replacingOccurrences(of: ">", with: "76beeec0-6ff2-4561-b737-4a1207b6b5ce")
    }
    
    var returnBrackets: String {
        return self
            .replacingOccurrences(of: "23bc876f-9322-4601-8be7-4cf660a0d33f", with: "<")
            .replacingOccurrences(of: "76beeec0-6ff2-4561-b737-4a1207b6b5ce", with: ">")
    }
}

extension PostDetailsViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated  {
            if let newURL = navigationAction.request.url {
                UIApplication.shared.open(newURL, options: [:]) { canBeOpen in
                    if canBeOpen {
                        decisionHandler(.cancel)
                    } else {
                        decisionHandler(.allow)
                    }
                }
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}

extension PostDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let nextContentOffsetY = scrollView.contentOffset.y
        let alreadyHidden = abs(navigationBarTopConstr.constant + 64) == 0
        
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height {
            // nothing
        } else if nextContentOffsetY < prevContentOffsetY || nextContentOffsetY < 5 {
            // Show
            if alreadyHidden == true {
                navigationBarTopConstr.constant = 0
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
        } else {
            if alreadyHidden == false {
                navigationBarTopConstr.constant = -64
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
        }
        
        prevContentOffsetY = nextContentOffsetY
    }
}
