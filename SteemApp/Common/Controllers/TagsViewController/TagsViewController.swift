//
//  TagsViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/28/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

class TagsViewController: UIViewController {
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var tagsStackView: UIStackView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    private weak var interfaceCoordinator: InterfaceCoordinator?
    
    convenience init(interfaceCoordinator: InterfaceCoordinator?) {
        self.init(nibName: "TagsViewController", bundle: nil)
        self.interfaceCoordinator = interfaceCoordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tagTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 58))
        tagTextField.leftViewMode = UITextFieldViewMode.always
        tagTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        // Restore tags
        SharedNote.shared.note?.tags.forEach({ append(tag: $0) })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        disableAddButtonIfNeed()
        disableNextButtonIfNeed()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tagTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SharedNote.shared.save()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        interfaceCoordinator?.rewards(self)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        interfaceCoordinator?.back(self)
    }
    
    @IBAction func addTagButtonAction(_ sender: Any) {
        guard let tag = tagTextField.text, 1..<25 ~= tag.letters.count else { return }
        
        append(tag: tag.letters.lowercased())
        tagTextField.text = "#"
        
        disableAddButtonIfNeed()
        disableNextButtonIfNeed()
        
        let tags = tagsStackView.arrangedSubviews.flatMap({ $0 as? TagView }).flatMap({ $0.titleLabel.text })
        SharedNote.shared.tags(set: tags)
    }
    
    private func append(tag: String) {
        let colorIdx = Int(arc4random() % 11)
        let tagColor = TagColor(rawValue: colorIdx) ?? TagColor.tag0
        let tagView = TagView.loadView(tag: tag, color: tagColor) { [weak self] in
            self?.disableAddButtonIfNeed()
            self?.disableNextButtonIfNeed()
        }
        
        tagsStackView.addArrangedSubview(tagView)
    }
    
    private func disableAddButtonIfNeed() {
        addButton.isEnabled = (tagsStackView.arrangedSubviews.count < 5)
    }

    private func disableNextButtonIfNeed() {
        nextButton.isEnabled = (tagsStackView.arrangedSubviews.count > 0)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        tagTextField.resignFirstResponder()
    }
}

extension TagsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let length = textField.text?.count ?? 0
        let emptyQ = string.isEmpty
        
        if string.contains(" "), length > 0, addButton.isEnabled {
            addTagButtonAction(addButton)
            tagTextField.text = "#"
        }
        
        return (length < 24) || (length >= 24 && emptyQ)
    }
}
