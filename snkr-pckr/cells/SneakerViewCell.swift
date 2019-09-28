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
        
        border.backgroundColor = Colors.pastelGrey.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        self.backView.layer.addSublayer(border)
    }
}
