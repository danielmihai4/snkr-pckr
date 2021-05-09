//
//  SnkrCategoryCollectionViewCell.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/05/2021.
//  Copyright © 2021 Daniel Mihai. All rights reserved.
//

import UIKit

class SnkrCategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorwayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //setupImageView()
    }
    
    func configure(snkr: Snkr) {
        if let smallPic = snkr.smallPic {
            self.imageView.image = smallPic
            self.imageView.clipsToBounds = true
            self.imageView.layer.cornerRadius = 5
        }
        
        self.nameLabel.text = snkr.name
        self.colorwayLabel.text = snkr.colorway
    }
}
