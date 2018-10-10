//
//  WebContentViewController.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 3/28/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import WebKit

class WebContentViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    private let urlString: String
    private var prefferedTitle: String = ""
    
    init(urlString: String, prefferedTitle: String) {
        self.prefferedTitle = prefferedTitle
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        let rbi = UIBarButtonItem(image: #imageLiteral(resourceName: "close_button_white"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(close(_:)))
        navigationItem.rightBarButtonItem = rbi
        title = prefferedTitle
    }
    
    
    @objc func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
