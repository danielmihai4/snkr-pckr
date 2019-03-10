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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        self.layer.borderColor = CellConstants.lightGray.cgColor
        self.backgroundColor = CellConstants.lightGray
        self.layer.masksToBounds = true
    }
}
