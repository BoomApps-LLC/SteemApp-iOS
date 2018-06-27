//
//  AlertViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/30/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    enum AlertViewControllerStyle {
        case message(msg: String, onDismiss: () -> ())
        case error(String)
    }
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    weak var interfaceCoordinator: InterfaceCoordinator?
    private var style: AlertViewControllerStyle?
    private var onDismiss: (() -> ())?
    
    convenience init(interfaceCoordinator: InterfaceCoordinator?,
                     style: AlertViewControllerStyle) {
        self.init(nibName: "AlertViewController", bundle: nil)
        self.interfaceCoordinator = interfaceCoordinator
        self.style = style
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureStyle()
        dissmiss(in: .now() + 3.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureStyle() {
        guard let style = self.style else { return }
        
        switch style {
        case .message(let msg, let dismiss):
            messageLabel.text = msg
            iconImageView.image = #imageLiteral(resourceName: "success_alerticon")
            onDismiss = dismiss
        case .error(let msg):
            messageLabel.text = msg
            iconImageView.image = #imageLiteral(resourceName: "fail_alerticon")
        }
    }
    
    private func dissmiss(in time: DispatchTime) {
        DispatchQueue.main.asyncAfter(deadline: time) { [weak self] in
            self?.interfaceCoordinator?.dismiss(self!, completion: self!.onDismiss)
        }
    }
}
