//
//  LoginViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/23/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform
import WebKit
import AVFoundation
import QRCodeReader

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var webViewConatiner: UIView!
    
    private weak var interfaceCoordinator: InterfaceCoordinator?
    private var authService: AuthService?
    private let myReaderView = MyReaderView()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.cancelButtonTitle = ""
            $0.showSwitchCameraButton = false
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.readerView = QRCodeReaderContainer(displayable: myReaderView)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    convenience init(interfaceCoordinator: InterfaceCoordinator?) {
        self.init(nibName: "LoginViewController", bundle: nil)
        self.interfaceCoordinator = interfaceCoordinator
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authService = ServiceLocator.Application.authService(webViewConatiner: webViewConatiner)
        configure()
        
        if let qrv = (myReaderView.cameraView as? QRReaderView) {
            qrv.infoButton.addTarget(self, action: #selector(cameraInfoAction(_:)), for: .touchUpInside)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configure() {
        usernameTxtField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 58))
        usernameTxtField.leftViewMode = UITextFieldViewMode.always
        
        passwordTxtField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 58))
        passwordTxtField.leftViewMode = UITextFieldViewMode.always
        
        let qrreader = UIButton(type: .custom)
        qrreader.setImage(#imageLiteral(resourceName: "qr_reader"), for: .normal)
        qrreader.frame = CGRect(x: 0, y: 0, width: 58, height: 58)
        qrreader.addTarget(self, action: #selector(scanAction(_:)), for: .touchUpInside)
        
        passwordTxtField.rightView = qrreader
        passwordTxtField.rightViewMode = UITextFieldViewMode.always
        
        usernameTxtField.delegate = self
        passwordTxtField.delegate = self
        
        self.passwordTxtField.isSecureTextEntry = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func loginActionHandler(_ sender: Any) {
        usernameTxtField.resignFirstResponder()
        passwordTxtField.resignFirstResponder()
        
        check()
    }
    
    @IBAction func signupActionHandler(_ sender: Any) {
        interfaceCoordinator?.signup()
    }
    
    @IBAction func infoAction(_ sender: Any) {
        self.interfaceCoordinator?.onboarding(contentType: .wif, onclose: nil)
    }
    
    @objc func cameraInfoAction(_ sender: Any) {
        readerVC.dismiss(animated: false) {
            self.interfaceCoordinator?.onboarding(contentType: .qr, onclose: {
                self.showScaning()
            })
        }
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardFrameEnd = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect else { return }
        let keyboardHeight = keyboardFrameEnd.size.height
        
        scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0)
        scrollView.contentOffset = CGPoint(x: 0.0, y: min(121.0, keyboardHeight))
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    private func check() {
        if (usernameTxtField.text?.count ?? 0) < 3 {
            interfaceCoordinator?.alert(presenter: self, style: .error("Invalid User name"))
            return
        } else if (passwordTxtField.text?.count ?? 0) < 10 {
            interfaceCoordinator?.alert(presenter: self, style: .error("Invalid Private posting key"))
            return
        }
        
        self.interfaceCoordinator?.showActivityIndicator(nil)
        authService?.validate(wif: passwordTxtField.text!, completion: { (res: Result<Bool>) in
            switch res {
            case .success(let validQ):
                if validQ {
                    let username = self.usernameTxtField.text!
                    let password = self.passwordTxtField.text!
                    self.authService?.validate(wif: password, username: username, completion: { (res: Result<Bool>) in
                        switch res {
                        case .success(let validQ):
                            if validQ {
                                self.interfaceCoordinator?.hideActivityIndicator({
                                    self.storeCredentials()
                                })
                            } else {
                                self.interfaceCoordinator?.hideActivityIndicator({
                                    self.interfaceCoordinator?.alert(presenter: self, style: .error("User name doesn't match with Posting key"))
                                })
                            }
                        case .error:
                            self.interfaceCoordinator?.hideActivityIndicator({
                                self.interfaceCoordinator?.alert(presenter: self, style: .error("Posting key and User password can't be validated"))
                            })
                        }
                    })
                } else {
                    self.interfaceCoordinator?.hideActivityIndicator({
                        self.interfaceCoordinator?.alert(presenter: self, style: .error("Invalid Private posting key"))
                    })
                }
            case .error:
                self.interfaceCoordinator?.hideActivityIndicator({
                    self.interfaceCoordinator?.alert(presenter: self, style: .error("Private key can't be validated"))
                })
            }
        })
    }
    
    private func storeCredentials() {
        let userService = ServiceLocator.Application.userService()
        userService.login(userName: usernameTxtField.text!, postingKey: passwordTxtField.text!) { (result: Result<Void>) in
            switch result {
            case .success:
                self.interfaceCoordinator?.logedIn()
            case .error:
                self.interfaceCoordinator?.alert(presenter: self, style: .error("Can't be saved"))
            }
        }
    }
    
    @IBAction func scanAction(_ sender: AnyObject) {
        let os = ServiceLocator.Application.onboardingService()
        os.skipedQrQ { (result) in
            if case .success(let skip) = result, (skip ?? false) == false {
                self.interfaceCoordinator?.onboarding(contentType: .qr, onclose: {
                    self.showScaning()
                })
            } else {
                self.showScaning()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func showScaning() {
        // Retrieve the QRCode content
        // By using the delegate pattern
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            guard let wif = result?.value else { return }
            self.passwordTxtField.text = wif
        }
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        present(readerVC, animated: true, completion: nil)
    }
    
    private func showWifOnboardingIfNeeded() {
        let os = ServiceLocator.Application.onboardingService()
        os.skipedWifQ { (result) in
            switch result {
            case .success(let skip):
                if (skip ?? false) == false {
                    self.interfaceCoordinator?.onboarding(contentType: .wif, onclose: nil)
                }
            case .error:
                break
            }
        }
    }
}

extension LoginViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTxtField {
            passwordTxtField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordTxtField {
            showWifOnboardingIfNeeded()
        }
    }
}
