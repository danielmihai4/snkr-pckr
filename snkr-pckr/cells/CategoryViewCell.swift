//
//  CategoryViewCellTableViewCell.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class CategoryViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var snkrCountLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, CellConstants.margins)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backView.layer.cornerRadius = CellConstants.cornerRadius
        self.backView.layer.masksToBounds = true
    }
}
