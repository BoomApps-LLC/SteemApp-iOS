//
//  CurrentRateNoteCell.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 8/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform

class CurrentRateNoteCell: UITableViewCell {
    @IBOutlet weak var leftCurrencyLabel: UILabel!
    
    static var identifier = "CurrentRateNoteCellIdentifier"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
