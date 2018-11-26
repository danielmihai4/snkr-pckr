//
//  ModalViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 25/11/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate: class {
    func cancelPickedSnkr()
    func confirmPickedSnkr(snkr: Snkr)
}

class ModalViewController: UIViewController {
    
    var snkr: Snkr!
    weak var delegate: ModalViewControllerDelegate?
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorwayLabel: UILabel!
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.cancelPickedSnkr()
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        delegate?.confirmPickedSnkr(snkr: snkr)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pic.image = snkr.pic
        nameLabel.text = snkr.name
        colorwayLabel.text = snkr.colorway        
    }
    
    override func viewDidLayoutSubviews() {
        view.backgroundColor = UIColor(white: 1, alpha: 0.9)
    }
    
}
