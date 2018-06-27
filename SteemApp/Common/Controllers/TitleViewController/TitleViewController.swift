//
//  TitleViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/28/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

class TitleViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleView: UITextView!
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    
    private weak var interfaceCoordinator: InterfaceCoordinator?
    private weak var sharedNote: SharedNote?
    
    convenience init(interfaceCoordinator: InterfaceCoordinator?) {
        self.init(nibName: "TitleViewController", bundle: nil)
        self.interfaceCoordinator = interfaceCoordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        // Restore tags
        titleView.text = SharedNote.shared.note?.title
        titleView.delegate = self
        showPlaceholderIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.titleView.becomeFirstResponder()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SharedNote.shared.save()
        NotificationCenter.default.removeObserver(self)
        
        titleView.resignFirstResponder()
    }
    
    func set(sharedNote: SharedNote?) {
        self.sharedNote = sharedNote
        
        let title = (sharedNote?.note?.title ?? "")
        
        titleView.text = title
        showPlaceholderIfNeeded()
        activateNextButtonIfNeeded(with: title)
    }
    
    private func activateNextButtonIfNeeded(with title: String) {
        nextButton.isEnabled = (title.letters.count > 0)
        nextButton.isHighlighted = nextButton.isEnabled
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        interfaceCoordinator?.newnote(self)
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        interfaceCoordinator?.dismiss(self, completion: nil)
    }
    
    private func showPlaceholderIfNeeded() {
        placeholderLabel.isHidden = (titleView.text.count > 0)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        titleView.resignFirstResponder()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TitleViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        SharedNote.shared.title(set: textView.text)
        showPlaceholderIfNeeded()
        activateNextButtonIfNeeded(with: textView.text)
    }
}

extension TitleViewController {
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        let duration = TimeInterval((notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.25)
        let curve = UInt((notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0)
        let options = UIViewAnimationOptions(rawValue: curve)
        
        guard let keyboardFrameEnd = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect else { return }
        let keyboardHeight = keyboardFrameEnd.size.height
        
        textViewBottom.constant = keyboardHeight
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        textViewBottom.constant = 0
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

