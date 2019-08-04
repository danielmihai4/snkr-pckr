//
//  SnkrSelectorCell.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 10/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class SnkrSelectorCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorwayLabel: UILabel!
    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var checkbox: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    var delegate: TableViewCellDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: CellConstants.margins)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backView.layer.cornerRadius = CellConstants.cornerRadius
        self.backView.layer.masksToBounds = true
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }
    
    @objc func doubleTapped() {
        delegate?.doubleTap(cell: self)
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("Superview is not a UITableView - getIndexPath")
            return nil
        }
        
        return superView.indexPath(for: self)
    }
    
}
