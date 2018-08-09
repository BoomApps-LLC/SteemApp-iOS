//
//  ProfileViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/30/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform
import Kingfisher
import MessageUI

class ProfileViewController: UIViewController, Page {
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var leftCurrencyLabel: UILabel!
    @IBOutlet weak var rightCurrencyLabel: UILabel!
    
    internal var identifier: String
    private weak var interfaceCoordinator: InterfaceCoordinator?
    private let walletSvc = ServiceLocator.Application.walletService()
    private let userSvc = ServiceLocator.Application.userService()
    
    init(identifier: String, interfaceCoordinator: InterfaceCoordinator?) {
        self.identifier = identifier
        self.interfaceCoordinator = interfaceCoordinator
        super.init(nibName: "ProfileViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImgView.layer.borderColor = UIColor.white.cgColor
        profileImgView.layer.borderWidth = 1.0
        profileImgView.layer.cornerRadius = profileImgView.frame.size.height / 2.0
        profileImgView.clipsToBounds = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAccount()
    }
    
    private func checkAccount() {
        self.userSvc.account { res in
            switch res {
            case .success(let account):
                if let urlStr = account.profile_image, let url = URL(string: urlStr) {
                    self.profileImgView.kf.setImage(with: url)
                }
                self.userNameLabel.text = account.name
            case .error(let err):
                DispatchQueue.main.async {
                    self.interfaceCoordinator?.alert(presenter: self, style: .error("Account data can't be load"))
                }
            }
        }
        
        self.walletSvc.balance { (result: Result<Double>) in
            switch result {
            case .success(let balance):
                let dollars = String(format: "%.2f", balance)
                self.balanceLabel.text = "$ \(dollars)"
            case .error:
                self.walletSvc.balanceCache { (result: Result<Double>) in
                    if case .success(let balance) = result {
                        let dollars = String(format: "%.2f", balance)
                        self.balanceLabel.text = "$ ~\(dollars)"
                    } else {
                        DispatchQueue.main.async {
                            self.interfaceCoordinator?.alert(presenter: self, style: .error("Data for balance calculation is not available"))
                        }
                    }
                }
            }
        }
        
        self.walletSvc.estimateOutputAmount(ict: Currency.steem, oct: Currency.bitusd) { res in
            if case .success(let cp) = res {
                DispatchQueue.main.async {
                    self.leftCurrencyLabel.text = "STEEM"
                    self.rightCurrencyLabel.text = "USD \(String(format: "%.4f", Float(cp.outputAmount) ?? 0))"
                }
            } else {
                DispatchQueue.main.async {
                    self.interfaceCoordinator?.alert(presenter: self, style: .error("Data for trades is not available"))
                }
            }
        }
    }
    

    @IBAction func sendFeedbackButtonAction(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@steemitapp.com"])
            mail.setMessageBody("<p>Let's do the SteemitApp better!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            self.interfaceCoordinator?.alert(presenter: self, style: .error("Can't be open mail client"))
        }
    }
    
    @IBAction func shareTheAppButtonAction(_ sender: Any) {
        //let textToShare = "Swift is awesome!  Check out this website about it!"
        
        if let myWebsite = NSURL(string: "https://steemitapp.com/") {
            let objectsToShare = [myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = (sender as! UIButton)
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func rateTheAppButtonAction(_ sender: Any) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/1354516246") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func logOutButtonAction(_ sender: Any) {
        let userService = ServiceLocator.Application.userService()
        
        userService.logout { (result: Result<Void>) in
            switch result {
            case .success:
                self.interfaceCoordinator?.logedOut()
            case .error:
                self.interfaceCoordinator?.alert(presenter: self, style: .error("Something went wrong"))
            }
        }
    }
    
    @IBAction func currentButtonAction(_ sender: Any) {
        interfaceCoordinator?.currency(completion: { })
    }
}

extension ProfileViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
