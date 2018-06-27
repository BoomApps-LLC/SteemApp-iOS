//
//  ActivityViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 2/10/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private weak var interfaceCoordinator: InterfaceCoordinator?
    
    convenience init(interfaceCoordinator: InterfaceCoordinator?) {
        self.init(nibName: "ActivityViewController", bundle: nil)
        self.interfaceCoordinator = interfaceCoordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        activityIndicator.startAnimating()
    }
}
