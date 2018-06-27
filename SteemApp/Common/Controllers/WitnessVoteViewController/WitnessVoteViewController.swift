//
//  WitnessVoteViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 4/3/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform

class WitnessVoteViewController: UIViewController {
    weak var interfaceCoordinator: InterfaceCoordinator?
    private var onClose: (() -> ())?
    private var onVote: (() -> ())?
    
    convenience init(interfaceCoordinator: InterfaceCoordinator?, onClose: @escaping () -> (), onVote: @escaping () -> ()) {
        self.init(nibName: "WitnessVoteViewController", bundle: nil)
        self.interfaceCoordinator = interfaceCoordinator
        self.onClose = onClose
        self.onVote = onVote
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func voteAction(_ sender: Any) {
        self.interfaceCoordinator?.dismiss(self, completion: {
            self.onVote?()
        })
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.interfaceCoordinator?.dismiss(self, completion: {
            self.onClose?()
        })
    }
}
