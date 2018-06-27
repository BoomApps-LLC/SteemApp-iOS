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
    @IBOutlet weak var activityView: UIVisualEffectView!
    
    private var webView: WKWebView!
    private weak var dataSource: FeedViewCellDataSource?
    private let item: Post
    private var contentOffsetY: CGFloat = 0
    private let username: String
    private weak var delegate: PostDetailsViewControllerDelegate?
    
    init(username: String, item: Post, dataSource: FeedViewCellDataSource, delegate: PostDetailsViewControllerDelegate) {
        self.item = item
        self.dataSource = dataSource
        self.delegate = delegate
        self.username = username
        
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
        webView.scrollView.delegate = self
        webViewContainer.addSubview(webView)
        webView.flipToBorder()
        
        activityView.isHidden = true
        
        tryParseAutomatic(item: item, otherwise: { item in
            self.parseManualy(item: item)
        })

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
        
        self.infoTotalPayoutValueButton.isSelected = true
        delegate?.vote(postDetailsViewController: self, permlink: permlink, author: author, completion: { sccfl in
            self.infoTotalPayoutValueButton.isSelected = sccfl
        })
    }
    
    private func parseManualy(item: Post) {
        let body = item.body.removeBrackets
        let down = Down(markdownString: body)
        let noteBody = try! down.toHTML(DownOptions.safe)
        let htmlContent = "<H1>" + item.title + "</H1>" + noteBody.returnBrackets
        
        set(content: htmlContent)
    }
    
    private func tryParseAutomatic(item: Post, otherwise: @escaping (Post) -> ()) {
        let body = item.body.removeBrackets
        let down = Down(markdownString: body)
        let noteBody = try! down.toHTML(DownOptions.safe).returnBrackets
        let clearedBody = removeLink(txt: noteBody)
        
        activityView.isHidden = false
        
        if let nu = URL(string: item.url, relativeTo: URL(string: "https://steemit.com")) {
            let session = URLSession.shared.dataTask(with: nu) { (data, response, error) in
                if let d = data {
                    let steemitHtml = String.init(data: d, encoding: String.Encoding.utf8)
                    let someContent = self.tryExtractFromSteemitcom(noteBody: clearedBody, steemcomHtml: steemitHtml)
                    
                    if let htmlContent = someContent {
                        let htmlContent = "<H1>" + item.title + "</H1>" + htmlContent
                        DispatchQueue.main.async {
                            self.set(content: htmlContent)
                            self.activityView.isHidden = true
                        }
                        
//                        DispatchQueue.main.async {
//                            self.webView.loadHTMLString(htmlContent, baseURL: URL(string: "https://")!)
//                        }
                    } else {
                        DispatchQueue.main.async {
                            self.activityView.isHidden = true
                            otherwise(item)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.activityView.isHidden = true
                        otherwise(item)
                    }
                }
            }
            
            session.resume()
        } else {
            activityView.isHidden = true
            otherwise(item)
        }
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
}

extension PostDetailsViewController {
    private func tryExtractFromSteemitcom(noteBody html1: String, steemcomHtml html2: String?) -> String? {
        guard let html2 = html2 else { return nil }
        
        var digests = [String]()
        
        // Parse html1
        do {
            let doc: Document = try SwiftSoup.parse(html1)
            if let elements = try doc.body()?.getElementsByTag("p") {
                for element in elements {
                    if let d = digest(element: element), d.isEmpty == false {
                        digests.append(d)
                    }
                }
            }
        } catch {
            return nil
        }
        
        // Parse html2
        let startDocKey = digests.first
        
        do {
            let doc: Document = try SwiftSoup.parse(html2)
            
            if let divs = try doc.body()?.getElementsByTag("div").filter({ element -> Bool in
                return element.children().filter({ $0.tagName() == "div" }).isEmpty
            }) {
                for div in divs {
                    let ps = try div.getElementsByTag("p")
                    for p in ps {
                        let dgst = digest(element: p)
                        
                        if dgst == startDocKey, let parentDiv = p.parent() {
                            let parentHtml = try parentDiv.outerHtml()
                            let siblingsHtml = try parentDiv.siblingElements().outerHtml()
                            
                            
                            let all = Element.init(Tag.init("div"), "steemit.com")
                            
                            try all.append(parentHtml)
                            try all.append(siblingsHtml)
                            
                            let body = try all.outerHtml()
                            return body
                            
                            //try doc.body()?.children().forEach({try $0.remove() })
                            //try doc.body()?.append(body)
                            
                            //return try doc.outerHtml()
                        }
                    }
                }
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    private func digest(element: Element) -> String? {
        do {
            var txt = try element.text()
            let rexexpr = try NSRegularExpression(pattern: "\\W+", options: NSRegularExpression.Options.caseInsensitive)
            let matches = rexexpr.matches(in: txt, options: [], range: NSRange(location: 0, length: txt.utf16.count))
            
            for match in matches.reversed() {
                guard let range = Range.init(match.range, in: txt) else { continue }
                txt.removeSubrange(range)
            }
            
            return txt
        } catch {
            return nil
        }
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

extension PostDetailsViewController: WKUIDelegate {
    
}

extension PostDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < contentOffsetY || scrollView.contentOffset.y < 5 {
            navigationBarTopConstr.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        } else {
            navigationBarTopConstr.constant = -64
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
        
        contentOffsetY = scrollView.contentOffset.y
    }
}
