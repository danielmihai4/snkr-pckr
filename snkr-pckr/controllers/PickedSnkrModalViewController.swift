//
//  ModalViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 25/11/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit

protocol PickedSnkrModalViewControllerDelegate: class {
    func cancelPickedSnkr()
    func confirmPickedSnkr(snkr: Snkr)
}

class PickedSnkrModalViewController: UIViewController {
    
    var snkr: Snkr!
    var snkrService = SnkrService()
    weak var delegate: PickedSnkrModalViewControllerDelegate?
    
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
        
        pic.image = snkrService.loadPic(snkr: snkr)
        nameLabel.text = snkr.name
        colorwayLabel.text = snkr.colorway        
    }
    
    override func viewDidLayoutSubviews() {
        let backgroundColor = self.view.backgroundColor
    
        self.view.backgroundColor = backgroundColor?.withAlphaComponent(0.95)
    }
    
}
