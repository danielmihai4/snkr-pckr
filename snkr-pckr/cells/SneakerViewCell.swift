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
        let margins = CellConstants.margins
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, margins)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.backView.layer.cornerRadius = CellConstants.cornerRadius
        self.backView.layer.masksToBounds = true
    }
}
