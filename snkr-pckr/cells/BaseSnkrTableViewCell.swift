//
//  BaseSnkrTableViewCell.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 14/12/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class BaseSnkrTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    
    var delegate: TableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestureRecognizer()
        addBottomBorder()
    }
    
    public func addTopBorder() {
        addBorder(x: 0, y: 0, width: self.backView.frame.width, height: CellConstants.borderSize)
    }
    
    public func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("Superview is not a UITableView - getIndexPath")
            return nil
        }
        
        return superView.indexPath(for: self)
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
    
    private func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }
    
    @objc func doubleTapped() {
        delegate?.doubleTap(cell: self)
    }
}
