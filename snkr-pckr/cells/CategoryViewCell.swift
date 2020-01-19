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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addBottomBorder()
    }
    
    public func addTopBorder() {
        addBorder(x: 0, y: 0, width: self.backView.frame.width, height: CellConstants.borderSize)
    }
    
    private func addBottomBorder() {
        addBorder(x: 0, y: self.backView.frame.height - CellConstants.borderSize, width: self.backView.frame.width, height: CellConstants.borderSize)
    }
    
    private func addBorder(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        let border = CALayer()
        
        border.backgroundColor = Colors.dustStorm.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        self.backView.layer.addSublayer(border)
    }
}
