//
//  NoteTextViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/27/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform

class NoteTextViewController: UIViewController {
    @IBOutlet weak var richEditorViewBottom: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var richTextViewContainer: UIView!
    
    // Magic flag
    var copyAlertShowed = false
    
    private let richTextEditorController = ZSSRichTextEditor()
    private weak var interfaceCoordinator: InterfaceCoordinator?
    
    convenience init(interfaceCoordinator: InterfaceCoordinator?) {
        self.init(nibName: "NoteTextViewController", bundle: nil)
        self.interfaceCoordinator = interfaceCoordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextEditor()
        
        let b = (SharedNote.shared.note?.body ?? "")
        richTextEditorController.setHTML(b)
        activateNextButtonIfNeeded(with: b)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let reachabilitySvc = ServiceLocator.Application.reachabilityService()
        reachabilitySvc.photoAccess(onAuthorized: {
            
        }, onNonauthorised: {
            DispatchQueue.main.async {
                self.interfaceCoordinator?.alert(presenter: self, style: .error("You will not be available upload photos."))
            }
        }, onRestricted: {
            
        }, onDenied: {
            
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let body = (self.richTextEditorController.getHTML() ?? "")
        SharedNote.shared.body(set: "<html>" + body + "</html>")
        SharedNote.shared.save()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureTextEditor() {
        guard let richTextEditorView = richTextEditorController.view else { return }
        
        self.addChildViewController(richTextEditorController)
        self.richTextViewContainer.addSubview(richTextEditorView)
        
        richTextEditorView.flipToBorder()
        self.richTextEditorController.didMove(toParentViewController: self)
        self.richTextEditorController.receiveEditorDidChangeEvents = true
        
        self.richTextEditorController.enabledToolbarItems = [ZSSRichTextEditorToolbarViewSource,
                                                             //ZSSRichTextEditorToolbarRemoveFormat,
                                                             ZSSRichTextEditorToolbarBold,
                                                             ZSSRichTextEditorToolbarItalic,
                                                             ZSSRichTextEditorToolbarStrikeThrough,
                                                             //ZSSRichTextEditorToolbarUnderline,
                                                             ZSSRichTextEditorToolbarH1,
                                                             ZSSRichTextEditorToolbarH2,
                                                             ZSSRichTextEditorToolbarH3,
                                                             //ZSSRichTextEditorToolbarParagraph,
                                                             ZSSRichTextEditorToolbarBlockquote,
                                                             ZSSRichTextEditorToolbarUnorderedList,
                                                             ZSSRichTextEditorToolbarOrderedList,
                                                             ZSSRichTextEditorToolbarHorizontalRule,
                                                             ZSSRichTextEditorToolbarInsertImageFromDevice,
                                                             //ZSSRichTextEditorToolbarInsertImage,
                                                             ZSSRichTextEditorToolbarInsertLink]
        
        self.richTextEditorController.delegate = self
        self.richTextEditorController.placeholder = "Write your story...";
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        interfaceCoordinator?.back(self)
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        let body = self.richTextEditorController.getHTML()
        
        guard let b = body, (b.letters.isEmpty == false) else {
            interfaceCoordinator?.alert(presenter: self, style: .error("Body can not be empty"))
            return
        }
        
        if body?.range(of: "webkit-fake-url:") != nil {
            interfaceCoordinator?.alert(presenter: self, style: .error("Some photos can't be upload because was copied and pasted. \nPlease use special button from Keyboard toolbar"))
            return
        }
        
        interfaceCoordinator?.tags(self)
    }
    
    private func activateNextButtonIfNeeded(with body: String) {
        nextButton.isEnabled = (body.letters.count > 0)
        nextButton.isHighlighted = nextButton.isEnabled
    }
    
    deinit {
        
    }
}

extension NoteTextViewController: ZSSRichTextEditorDelegate {
    func richTextEditor(_ richTextEditor: ZSSRichTextEditor!, didChangeWithText text: String!, andHTML html: String!) {
        if copyAlertShowed == false, html.range(of: "webkit-fake-url:") != nil {
            copyAlertShowed = true
            interfaceCoordinator?.alert(presenter: self, style: .error("Some photos can't be upload because was copied and pasted"))
        }
        
        activateNextButtonIfNeeded(with: html)
    }
    
    func richTextEditor(_ richTextEditor: ZSSRichTextEditor!, didAddLink path: String!, localIdentifier someIdentifier: String!) {
        SharedNote.shared.note?.assets[path] = someIdentifier ?? "error"
    }
}

extension NoteTextViewController {
    
}

extension NoteTextViewController {
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        let duration = TimeInterval((notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.25)
        let curve = UInt((notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0)
        let options = UIViewAnimationOptions(rawValue: curve)
        
        guard let keyboardFrameEnd = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect else { return }
        let keyboardHeight = keyboardFrameEnd.size.height
        
        richEditorViewBottom.constant = keyboardHeight
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        richEditorViewBottom.constant = 0
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}
