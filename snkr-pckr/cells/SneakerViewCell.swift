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
        
        let lightGray = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        
        self.backView.layer.cornerRadius = 10
        self.backView.layer.borderColor = lightGray.cgColor
        self.backView.backgroundColor = lightGray
        self.backView.layer.masksToBounds = true
    }
}
