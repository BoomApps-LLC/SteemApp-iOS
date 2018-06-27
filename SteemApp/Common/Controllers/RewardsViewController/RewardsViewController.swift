//
//  RewardsViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/28/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import WebKit
import Platform

class RewardsViewController: UIViewController {
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var rewardsPowerUpButton: UIButton!
    @IBOutlet weak var rewardsSteemFiftyButton: UIButton!
    @IBOutlet weak var rewardsSteemNullButton: UIButton!
    @IBOutlet weak var upvoteSwitcher: UISwitch!
    @IBOutlet weak var webViewConatiner: UIView!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    
    private weak var interfaceCoordinator: InterfaceCoordinator?
    private weak var sharedNote: SharedNote?
    
    private var broadcastSvc: (BroadcastService & UploadService)?
    private let userSvc = ServiceLocator.Application.userService()
    private let witnessSvc = ServiceLocator.Application.witnessService()
    
    convenience init(interfaceCoordinator: InterfaceCoordinator?, note: SharedNote?) {
        self.init(nibName: "RewardsViewController", bundle: nil)
        self.interfaceCoordinator = interfaceCoordinator
        self.sharedNote = note
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.broadcastSvc = ServiceLocator.Application.broadcastService(webViewConatiner: webViewConatiner)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        validatePost()
        toogleRewardsAction(rewardsSteemFiftyButton)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        if stackViewHeight.constant > rewardsPowerUpButton.frame.size.width {
            stackViewHeight.constant = rewardsPowerUpButton.frame.size.width
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    private func validatePost() {
        postButton.isEnabled = (sharedNote?.validQ ?? false)
    }
    
    @IBAction func postButtonAction(_ sender: Any) {
        userSvc.logedQ { result in
            switch result {
            case .success(let someCreds):
                if case .some(let creds) = someCreds {
                    if self.sharedNote?.note?.assets.count ?? 0 > 0 {
                        let reachabilitySvc = ServiceLocator.Application.reachabilityService()
                        reachabilitySvc.photoAccess(onAuthorized: {
                            self.prepare(author: creds.username, wif: creds.postingKey)
                        }, onNonauthorised: {
                            DispatchQueue.main.async {
                                self.interfaceCoordinator?.alert(presenter: self, style: .error("You have not granted SteemApp access to your media library. Please check phone Settings..."))
                            }
                        }, onRestricted: {
                            DispatchQueue.main.async {
                                self.interfaceCoordinator?.alert(presenter: self, style: .error("You have not granted SteemApp access to your media library. Please check phone Settings..."))
                            }
                        }, onDenied: {
                            DispatchQueue.main.async {
                                self.interfaceCoordinator?.alert(presenter: self, style: .error("You have not granted SteemApp access to your media library. Please check phone Settings..."))
                            }
                        })
                    } else {
                        self.prepare(author: creds.username, wif: creds.postingKey)
                    }
                    
                    
                } else {
                    self.interfaceCoordinator?.alert(presenter: self, style: .error("Credentials can't be fetched"))
                }
            case .error:
                self.interfaceCoordinator?.alert(presenter: self, style: .error("Credentials can't be fetched"))
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        interfaceCoordinator?.back(self)
    }
    
    @IBAction func toogleRewardsAction(_ button: UIButton) {
        if button == rewardsPowerUpButton {
            rewardsPowerUpButton.isSelected = true
            rewardsSteemFiftyButton.isSelected = false
            rewardsSteemNullButton.isSelected = false
            
        } else if button == rewardsSteemFiftyButton {
            rewardsPowerUpButton.isSelected = false
            rewardsSteemFiftyButton.isSelected = true
            rewardsSteemNullButton.isSelected = false
            
        } else if button == rewardsSteemNullButton {
            rewardsPowerUpButton.isSelected = false
            rewardsSteemFiftyButton.isSelected = false
            rewardsSteemNullButton.isSelected = true
            
        }
    }
    
    private func prepare(author: String, wif: String) {
        guard let title = sharedNote?.note?.title,
            let rawbody = sharedNote?.note?.body,
            let tags = sharedNote?.note?.tags,
            let assets = sharedNote?.note?.assets
            else {
                interfaceCoordinator?.alert(presenter: self, style: .error("Missing parameters"))
                return
        }
        
        var mutableString = NSMutableString(string: title.lowercased()) as CFMutableString
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        let permlinkCandidate = (mutableString as String).permlink
        let permlink = (permlinkCandidate.isEmpty == false ? permlinkCandidate : UUID().uuidString)
        
        
        interfaceCoordinator?.showPostingProgress(nil)
        
        
        // Upload images
        broadcastSvc?.take(assets: assets, completion: { (result: Result<[ImageAsset]>) in
            switch result {
            case .success(let imageAssets):
                self.interfaceCoordinator?.updatePostingProgress(status: UploadProgressStatus.extracting(true))
                
                self.broadcastSvc?.sign(assets: imageAssets, wif: wif, completion: { (result: Result<[SignedData]>) in
                    switch result {
                    case .success(let signedAssets):
                        self.interfaceCoordinator?.updatePostingProgress(status: UploadProgressStatus.signing(true))
                        self.broadcastSvc?.upload(items: signedAssets, username: author, completion: { (result: Result<[SignedLinks]>) in
                            switch result {
                            case .success(let signedLinks):
                                self.interfaceCoordinator?.updatePostingProgress(status: UploadProgressStatus.uploading(true))
                                let links = signedLinks.map({ $0.link })
                                var body = rawbody
                                signedLinks.forEach({ (signedLink) in
                                    body = body.replacingOccurrences(of: signedLink.path, with: signedLink.link)
                                })

                                let comment = BroadcastComment(parent_author: "", parent_permlink: tags.first!,
                                                               author: author, permlink:permlink, title: title,
                                                               body: body, tags: tags, links: links)

                                let options = self.broadcastCommentOptions(author: author, permlink: permlink)
                                let vote = self.votes(author: author, permlink: permlink)

                                self.broadcastSvc?.broadcastSend(wif: wif, comment: comment,
                                                            options: options, vote: vote, completion: {(result: Result<Bool>) in
                                                                self.interfaceCoordinator?.updatePostingProgress(status: UploadProgressStatus.posting(true))
                                                                switch result {
                                                                case .success(let sscc):
                                                                    if sscc {
                                                                        self.witnessSvc.increaseSuccessCount(completion: {
                                                                            self.interfaceCoordinator?.hidePostingProgress({
                                                                                let dismiss: () -> () = { [weak self] in
                                                                                    self!.witnessSvc.witnessNeedShow(completion: { needShow in
                                                                                        if needShow {
                                                                                            self!.interfaceCoordinator?.witnessVote(presenter: self!, onClose: {
                                                                                                SharedNote.shared.delete(completion: {
                                                                                                    self!.interfaceCoordinator?.dismiss(self!, completion: {
                                                                                                        
                                                                                                    })
                                                                                                })
                                                                                            }, onVote: {
                                                                                                self!.witnessSvc.dontShowAgain {
                                                                                                    SharedNote.shared.delete(completion: {
                                                                                                        self!.interfaceCoordinator?.dismiss(self!, completion: {
                                                                                                            self!.interfaceCoordinator?.vote {
                                                                                                                
                                                                                                            }
                                                                                                        })
                                                                                                    })
                                                                                                }
                                                                                            })
                                                                                        } else {
                                                                                            SharedNote.shared.delete(completion: {
                                                                                                self!.interfaceCoordinator?.dismiss(self!, completion: {
                                                                                                    
                                                                                                })
                                                                                            })
                                                                                        }
                                                                                    })
                                                                                }
                                                                                
                                                                                guard let navigationController = self.navigationController else { return }
                                                                                self.interfaceCoordinator?.alert(presenter: navigationController,
                                                                                                                 style: .message(msg: "Your post has been successfully published",
                                                                                                                                 onDismiss: dismiss))
                                                                            })
                                                                        })
                                                                    } else {
                                                                        self.interfaceCoordinator?.hidePostingProgress({
                                                                            self.interfaceCoordinator?.alert(presenter: self, style: .error("Something went wrong"))
                                                                        })
                                                                    }
                                                                case .error:
                                                                   self.interfaceCoordinator?.hidePostingProgress({
                                                                       self.interfaceCoordinator?.alert(presenter: self, style: .error("Something went wrong"))
                                                                   })
                                                                }
                                })
                                
                            case .error:
                                self.interfaceCoordinator?.hidePostingProgress({
                                    self.interfaceCoordinator?.alert(presenter: self, style: .error("Images can't be uploaded"))
                                })
                            }
                        })
                    case .error:
                        self.interfaceCoordinator?.hidePostingProgress({
                            self.interfaceCoordinator?.alert(presenter: self, style: .error("Images can't be signed"))
                        })
                    }
                })
            case .error:
                self.interfaceCoordinator?.hidePostingProgress({
                    self.interfaceCoordinator?.alert(presenter: self, style: .error("Images can't be extracted from library"))
                })
                
            }
        })
    }
    
    private func broadcastCommentOptions(author: String, permlink: String) -> BroadcastCommentOptions? {
        if rewardsPowerUpButton.isSelected == true {
            return BroadcastCommentOptions(author: author,
                                           permlink: permlink,
                                           max_accepted_payout: "1000000.000 SBD",
                                           percent_steem_dollars: 0,
                                           allow_votes: true,
                                           allow_curation_rewards: true,
                                           extensions: [String]())
        } else if rewardsSteemNullButton.isSelected == true {
            return BroadcastCommentOptions(author: author,
                                           permlink: permlink,
                                           max_accepted_payout: "0.000 SBD",
                                           percent_steem_dollars: 10000,
                                           allow_votes: true,
                                           allow_curation_rewards: true,
                                           extensions: [String]())
        } else {
            return nil
        }
    }
    
    private func votes(author: String, permlink: String) -> BroadcastVote? {
        if upvoteSwitcher.isOn {
            return BroadcastVote(voter: author, author: author, permlink: permlink, weight: 10000)
        } else {
            return nil
        }
    }
}
