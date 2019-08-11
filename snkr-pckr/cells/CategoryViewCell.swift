//
//  CategoryViewCellTableViewCell.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import FoldingCell

protocol CategoryViewCellDelegate {
    func showOptions(for cell: CategoryViewCell)
}

class CategoryViewCell: FoldingCell {

    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var noSnkrsLabel: UILabel!    
    @IBOutlet weak var unfoldedCategoryNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: CategoryViewCellDelegate?
    
    override func awakeFromNib() {
        self.foregroundView.layer.cornerRadius = CellConstants.cornerRadius
        self.foregroundView.layer.masksToBounds = true
        
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        delegate?.showOptions(for: self)
    }
    
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("Superview is not a UITableView - getIndexPath")
            return nil
        }
        
        return superView.indexPath(for: self)
    }
    
}
