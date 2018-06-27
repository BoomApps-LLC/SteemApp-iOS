//
//  ProgressView.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 6/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

public final class ProgressView: UIView {
    private var activityIndicator = UIActivityIndicatorView(frame: CGRect.zero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clear
        
        self.addSubview(activityIndicator)
        
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.hidesWhenStopped = true
        activityIndicator.flipToBorder()
    }
    
    func appearAnimate(completion: @escaping () -> ()) {
        self.isHidden = false
        
        UIView.animate(withDuration: 0.2, animations: {
            self.activityIndicator.startAnimating()
        }) { _ in
            completion()
        }
    }
    
    func disappearAnimate(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0.2, animations: {
            self.activityIndicator.stopAnimating()
        }) { _ in
            self.isHidden = true
            completion()
        }
    }
}
