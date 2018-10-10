//
//  FeedViewCell.swift
//  SteemApp
//
//  Created by Siarhei Suliukou on 5/7/18.
//  Copyright © 2018 mby4boomapps. All rights reserved.
//

import UIKit
import Kingfisher
import Platform

protocol FeedViewCellDataSource: class {
    var postRewards: PostReward? { get }
    func account(author: String) -> Account?
}

protocol FeedViewCellDelegate: class {
    func vote(feedViewCell: FeedViewCell, permlink: String, author: String, completion: @escaping (Bool) -> ())
    func showActivityIndicator()
    func hideActivityIndicator()
}

class FeedViewCell: UICollectionViewCell {
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var infoUserNameLabel: UILabel!
    @IBOutlet weak var infoTimeLabel: UILabel!
    @IBOutlet weak var infoNetVotesButton: UIButton!
    @IBOutlet weak var infoChildrenButton: UIButton!
    @IBOutlet weak var infoRepliesButton: UIButton!
    @IBOutlet weak var infoTotalPayoutValueButton: UIButton!
    @IBOutlet weak var mainImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var infoReputationLabel: UILabel!
    
    private var item: Post?
    private weak var dataSource: FeedViewCellDataSource?
    private weak var delegate: FeedViewCellDelegate?
    
    
    
    static func height(item: Post, body: String?) -> CGFloat {
        var height: CGFloat = 344.0 // START HEIGHT
        let title = item.title
        
        height -= 105.0 // IMAGE HHEIGHT
        height -= 50.0 // TITLE HEIGHT
        height -= 61.0 // BODY HEIGHT
        
        // Calculate visible elements
        if let img_url_str = item.cover_image, URL(string: img_url_str) != nil {
            height += 105.0
        }
        
        let titleFont = UIFont(name: "SFProDisplay-Regular", size: 22) ?? UIFont.systemFont(ofSize: 22)
        let bodyFont = UIFont(name: "SFProDisplay-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
        
        // 40.0 - collection view insets
        // 40.0 - cell labels insets
        let width = UIScreen.main.bounds.size.width - 40.0 - 40.0
        let eth = estimateHeight(withConstrWidth: width, font: titleFont, text: title) ?? 0
        let ebh = estimateHeight(withConstrWidth: width, font: bodyFont, text: body) ?? 44 // Otherwise image height
        
        height += min(eth, 50.0)
        height += min(ebh, 61.0)
        
        return height
    }
    
    private static func estimateHeight(withConstrWidth width: CGFloat, font: UIFont, text: String?) -> CGFloat? {
        guard let txt = text else { return nil }
        
        let constraintSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = txt.boundingRect(with: constraintSize,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        
        return ceil(boundingBox.height)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        //self.layer.borderColor = UIColor.white.cgColor
        //self.layer.borderWidth = 1.0
        
        self.infoImageView.layer.cornerRadius = 15
        self.infoImageView.layer.masksToBounds = true
    }

    func configure(username: String, item: Post, body: String?, dataSource: FeedViewCellDataSource, delegate: FeedViewCellDelegate) {
        self.item = item
        self.delegate = delegate
        self.dataSource = dataSource
        
        if let img_url_str = item.cover_image, let img_url = URL(string: img_url_str) {
            mainImageView.kf.setImage(with: img_url)
            mainImageView.isHidden = false
            mainImageViewHeight.constant = 105
        } else {
            mainImageViewHeight.constant = 0
            mainImageView.isHidden = true
        }
        
        titleLabel.text = item.title
        bodyLabel.text = body
        
        infoUserNameLabel.text = item.author
        
        if let acc = dataSource.account(author: item.author), let some_img = acc.profile_image, let img_url = URL(string: some_img) {
            self.infoImageView.kf.setImage(with: img_url)
            
            self.infoReputationLabel.text = String(format: "%0.0f", acc.reputation)
        } else {
            self.infoImageView.kf.setImage(with: nil)
        }
        
        if let acc = dataSource.account(author: item.author) {
            self.infoReputationLabel.text = String(format: "%0.0f", acc.reputation)
        } else {
            self.infoReputationLabel.text = String(format: "%0.0f", "0")
        }
        
        infoTimeLabel.text = item.createdText
        infoNetVotesButton.setTitle("\(item.active_votes.count)", for: .normal)
        infoChildrenButton.setTitle("\(item.children)", for: .normal)
        infoRepliesButton.setTitle("\(item.replies.count)", for: .normal)
        infoTotalPayoutValueButton.isSelected = (item.active_votes.first(where: { av -> Bool in
            return av.voter == username
        }) != nil)
        
        let pv = item.total_payout_value.double + item.curator_payout_value.double
        
        if pv > 0 {
            infoTotalPayoutValueButton.setTitle(String(format: "%0.2f", pv), for: .normal)
        } else {
            var cost: Double = 0.0
            
            if let pr = dataSource.postRewards {
                cost = item.active_votes.reduce(0, { (res, actVote) -> Double in
                    res + Double(actVote.rshares) * pr.reward_balance / pr.recent_claims * pr.base
                })
            }
            
            self.infoTotalPayoutValueButton.setTitle(String(format: "%0.2f", cost), for: .normal)
        }
    }
    
    @IBAction func infoTotalPayoutValueAction(_ sender: Any) {
        guard let permlink = item?.permlink, let author = item?.author  else { return }
        
        delegate?.showActivityIndicator()
        delegate?.vote(feedViewCell: self, permlink: permlink, author: author, completion: { sccfl in
            self.infoTotalPayoutValueButton.isSelected = sccfl
            self.delegate?.hideActivityIndicator()
        })
    }
}
