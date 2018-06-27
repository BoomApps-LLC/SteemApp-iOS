//
//  DataViewController.swift
//  TestPages
//
//  Created by Siarhei Suliukou on 3/21/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

struct OnboardingData {
    let index: Int
    let title: String
    let subtitle: String
    let imageName: String
}

class OnboardingDataViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var onboardingData: OnboardingData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let onboardingData = onboardingData {
            titleLabel.text = onboardingData.title
            subtitleLabel.text = onboardingData.subtitle
            imageView.image = UIImage.init(named: onboardingData.imageName)
        }
    }


}

