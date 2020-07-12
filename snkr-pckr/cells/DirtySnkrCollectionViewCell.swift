//
//  DirtySnkrCollectionViewCell.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 28/06/2020.
//  Copyright © 2020 Daniel Mihai. All rights reserved.
//

import UIKit

class DirtySnkrCollectionViewCell: UICollectionViewCell {
 
    var delegate: CollectionViewCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorwayLabel: UILabel!
    
    override func awakeFromNib() {
       super.awakeFromNib()
       
       setupGestureRecognizer()
       setupImageView()
    }
   
    func configure(snkr: Snkr) {
       self.imageView.image = snkr.smallPic
       self.nameLabel.text = snkr.name
       self.colorwayLabel.text = snkr.colorway
    }
    
    public func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UICollectionView else {
            print("Superview is not a UICollectionView - getIndexPath")
            return nil
        }
        
        return superView.indexPath(for: self)
    }
    
    private func setupGestureRecognizer() {
       let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
       doubleTap.numberOfTapsRequired = 2
       addGestureRecognizer(doubleTap)
    }
   
    private func setupImageView() {
       self.imageView.clipsToBounds = true
       self.imageView.layer.cornerRadius = 5
    }
   
    @objc func doubleTapped() {
       delegate?.doubleTap(cell: self)
    }        
}
