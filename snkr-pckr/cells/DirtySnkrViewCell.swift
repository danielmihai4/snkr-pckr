//
//  DirtySnkrViewCell.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 02/12/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit

protocol TableViewCellDelegate {
    func doubleTap(cell: UITableViewCell)
}

class DirtySnkrViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorwayLabel: UILabel!
    @IBOutlet weak var pic: UIImageView!
    
    var delegate: TableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let margins = UIEdgeInsetsMake(0, 0, 0, 0)  //set the values for top,left,bottom,right margins
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, margins)
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
