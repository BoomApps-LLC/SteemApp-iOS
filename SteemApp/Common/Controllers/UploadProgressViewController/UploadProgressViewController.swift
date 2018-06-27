//
//  UploadProgressViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 3/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

enum UploadProgressStatus {
    case extracting(Bool)
    case signing(Bool)
    case uploading(Bool)
    case posting(Bool)
}

class UploadProgressViewController: UIViewController {
    @IBOutlet weak var extractingImageView: UIImageView!
    @IBOutlet weak var signingImageView: UIImageView!
    @IBOutlet weak var uploadingImageView: UIImageView!
    @IBOutlet weak var postingImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update(status: UploadProgressStatus) {
        switch status {
        case .extracting(let success):
            extractingImageView.image = (success ? #imageLiteral(resourceName: "success_progress") : #imageLiteral(resourceName: "fail_progress") )
        case .signing(let success):
            signingImageView.image = (success ? #imageLiteral(resourceName: "success_progress") : #imageLiteral(resourceName: "fail_progress") )
        case .uploading(let success):
            uploadingImageView.image = (success ? #imageLiteral(resourceName: "success_progress") : #imageLiteral(resourceName: "fail_progress") )
        case .posting(let success):
            postingImageView.image = (success ? #imageLiteral(resourceName: "success_progress") : #imageLiteral(resourceName: "fail_progress") )
        }
    }
}
