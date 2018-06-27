//
//  TagView.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 1/28/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit

enum TagColor: Int {
    case tag0 = 0
    case tag1 = 1
    case tag2 = 2
    case tag3 = 3
    case tag4 = 4
    case tag5 = 5
    case tag6 = 6
    case tag7 = 7
    case tag8 = 8
    case tag9 = 9
    case tag10 = 10
    
    var image: UIImage {
        switch self {
        case .tag0:
            return #imageLiteral(resourceName: "tag_1")
        case .tag1:
            return #imageLiteral(resourceName: "tag_2")
        case .tag2:
            return #imageLiteral(resourceName: "tag_3")
        case .tag3:
            return #imageLiteral(resourceName: "tag_4")
        case .tag4:
            return #imageLiteral(resourceName: "tag_5")
        case .tag5:
            return #imageLiteral(resourceName: "tag_6")
        case .tag6:
            return #imageLiteral(resourceName: "tag_7")
        case .tag7:
            return #imageLiteral(resourceName: "tag_8")
        case .tag8:
            return #imageLiteral(resourceName: "tag_9")
        case .tag9:
            return #imageLiteral(resourceName: "tag_10")
        case .tag10:
            return #imageLiteral(resourceName: "tag_11")
        }
    }
}

final class TagView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    private var removeComletion: () -> () = {}
    var value: String? {
        return titleLabel.text
    }
    
    static func loadView(tag: String, color: TagColor, removeComletion: @escaping () -> ()) -> TagView {
        let nibs = Bundle.main.loadNibNamed("TagView", owner: self, options: nil)
        let nib = nibs?.first(where: { view -> Bool in
            return view is TagView
        })
        
        guard let tagView = nib as? TagView else { fatalError("There is no TagView") }
        
        tagView.titleLabel.text = tag
        tagView.backgroundImageView.image = color.image
        tagView.removeComletion = removeComletion
        
        return tagView
    }
    
    @IBAction func removeButtonAction(_ sender: Any) {
        self.removeFromSuperview()
        removeComletion()
    }
}
