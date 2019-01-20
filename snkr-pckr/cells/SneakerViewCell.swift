//
//  SneakerViewCell.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 17/11/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit

class SnkrTableViewCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorwayLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var pic: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let margins = UIEdgeInsetsMake(0, 0, 1, 0)  //set the values for top, left, bottom, right margins
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, margins)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backView.layer.cornerRadius = 10
        self.backView.layer.borderColor = UIColor.clear.cgColor
        self.backView.backgroundColor = UIColor.clear
        self.backView.layer.masksToBounds = true
        
        self.layer.shadowOpacity = 0.35
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 3
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.masksToBounds = false
        
    }
}
