//
//  CurrentRateCell.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 8/1/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Platform

class CurrentRateCell: UITableViewCell {
    @IBOutlet weak var leftCurrencyLabel: UILabel!
    @IBOutlet weak var rightCurrencyLabel: UILabel!
    
    static var identifier = "CurrentRateCellIdentifier"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(cp: CurrencyPair) {
        guard let ict = Currency.init(rawValue: cp.inputCoinType),
            let oct = Currency.init(rawValue: cp.outputCoinType) else { return }
        
        leftCurrencyLabel.text = "\(ict.lbl)"
        rightCurrencyLabel.text = "\(oct.lbl) \(String(format: "%.4f", Float(cp.outputAmount) ?? 0))"
    }
    
}
