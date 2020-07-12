//
//  SnkrCollectionViewCell.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 27/06/2020.
//  Copyright © 2020 Daniel Mihai. All rights reserved.
//

import UIKit

class SnkrCollectionViewCell: UICollectionViewCell {
    
    var delegate: CollectionViewCellDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorwayLabel: UILabel!
    @IBOutlet weak var lastWornDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupGestureRecognizer()
        setupImageView()
    }
    
    func configure(snkr: Snkr) {
        if let smallPic = snkr.smallPic {
            self.imageView.image = smallPic
        }
        
        self.nameLabel.text = snkr.name
        self.colorwayLabel.text = snkr.colorway
        self.lastWornDateLabel.text = DateUtils.formatDate(lastWornDate: snkr.lastWornDate)
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
