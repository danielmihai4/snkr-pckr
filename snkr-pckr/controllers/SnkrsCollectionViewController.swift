    //
//  SnkrsCollectionViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 27/06/2020.
//  Copyright © 2020 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit
import YPImagePicker

class SnkrsCollectionViewController: UICollectionViewController, CollectionViewCellDelegate, PopUpOptionsControlleDelegate, ConfirmationPopupDelegate, PickedSnkrModalViewControllerDelegate {
    
    var snkrs = [Snkr]() {
        didSet {
            self.setTitle()
        }
    }
    var snkrService = SnkrService()
    var snkrToView: Snkr?
    var snkrToEdit: Snkr?
    var snkrToDelete: Snkr?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadSnkrs()
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snkrs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let snkrCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.SnkrCollectionCell, for: indexPath) as? SnkrCollectionViewCell {
            snkrCollectionCell.configure(snkr: snkrs[indexPath.row])
            snkrCollectionCell.delegate = self
            snkrCollectionCell.layer.borderColor = Colors.dustStorm.cgColor
            snkrCollectionCell.layer.borderWidth = 1
            
            cell = snkrCollectionCell
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Segues.ShowPickedSnkr {
                if let viewController = segue.destination as? PickedSnkrModalViewController {
                    viewController.delegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    viewController.snkr = self.snkrToView == nil ? pickRandomSnkr() : self.snkrToView
                    
                    self.snkrToView = nil
                }
            } else if identifier == Segues.ShowNewSnkrViewSegue {
                if snkrToEdit != nil {
                    if let viewController = segue.destination as? NewSnkrViewController {
                        viewController.snkrToEdit = snkrToEdit
                    }
                } else {
                    let picker = YPImagePicker(configuration: PickerConfiguration.configuration())
                    picker.didFinishPicking { [unowned picker] items, _ in
                        if let photo = items.singlePhoto {
                            if let viewController = segue.destination as? NewSnkrViewController {
                                viewController.selectedImage = photo.image
                            }
                        }
                        picker.dismiss(animated: true, completion: nil)
                    }
                    present(picker, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        snkrToEdit = nil
    }
    
    @IBAction func saveSnkr(segue:UIStoryboardSegue) {
        if let source = segue.source as? NewSnkrViewController {
            if snkrToEdit != nil {
                let snkr = snkrs.filter{ $0.id == snkrToEdit?.id }.first
                snkr?.name = source.nameTextField.text!
                snkr?.colorway = source.colorwayTextField.text!
                snkr?.pic = source.imageView.image?.resized(toWidth: 375)
                snkr?.smallPic = source.imageView.image!.resized(toWidth: 120)
                
                self.collectionView.reloadData()
                self.snkrService.update(snkr: snkr!)
                self.snkrToEdit = nil
            } else {
                let snkr = Snkr(
                    id: UUID(),
                    name: source.nameTextField.text!,
                    colorway: source.colorwayTextField.text!,
                    lastWornDate: nil,
                    isClean: true,
                    pic: source.imageView.image!.resized(toWidth: 375),
                    smallPic: source.imageView.image!.resized(toWidth: 120))
                
                self.snkrs.append(snkr)
                self.collectionView.reloadData()
                        
                self.snkrService.store(snkr: snkr)
            }
        }
    }
    
    func doubleTap(cell: UICollectionViewCell) {
        if let snkrCollectionCell = cell as? SnkrCollectionViewCell {
            let indexPath = collectionView.indexPath(for: snkrCollectionCell)
            let snkr = snkrs[(indexPath?.row)!]
            let contentView = SnkrOptionsPopupView(with: self, snkr: snkr)
            
            SwiftEntryKit.display(entry: contentView, using: contentView.getAttributes(), presentInsideKeyWindow: true)
        }
    }
    
    internal func viewSnkr(_ snkr: Snkr) {
        self.snkrToView = snkr
        
        performSegue(withIdentifier: Segues.ShowPickedSnkr, sender: nil)
    }
    
    internal func editSnkr(_ snkr: Snkr) {
        self.snkrToEdit = snkr
        
        performSegue(withIdentifier: Segues.ShowNewSnkrViewSegue, sender: nil)
    }
   
    internal func deleteSnkr(_ snkr: Snkr) {
       snkrToDelete = snkr
       
       let confirmationPopup = ConfirmationPopup(title: PopUpLabels.confirmDeleteSnkrPopupTitle, image: snkr.pic, delegate: self)
       
       SwiftEntryKit.display(entry: confirmationPopup.getContentView(), using: confirmationPopup.getAttributes())
    }
   
    internal func toggleWearState(_ snkr: Snkr) {
       snkr.lastWornDate = snkr.lastWornDate != nil ? nil : Date()
       
       self.snkrService.update(snkr: snkr)
       self.collectionView.reloadData()
    }
   
    internal func markToClean(_ snkr: Snkr) {
       snkr.isClean = false
       
       snkrService.update(snkr: snkr)
    }
    
    internal func performCancelAction() {
        snkrToDelete = nil
    }
    
    internal func performConfirmAction() {
        let index = self.snkrs.firstIndex{$0 === snkrToDelete}
        let indexPath = IndexPath(row: index!, section: 0)
        
        self.snkrs.remove(at: indexPath.row)
        self.collectionView.deleteItems(at: [indexPath])
        self.snkrService.delete(snkr: self.snkrToDelete!)
    }
    
    internal func cancelPickedSnkr() {
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
    }
    
    internal func confirmPickedSnkr(snkr: Snkr) {
        for iteratorSnkr in snkrs {
            if iteratorSnkr.name == snkr.name && iteratorSnkr.colorway == snkr.colorway {
                iteratorSnkr.lastWornDate = Date()
                self.snkrService.update(snkr: snkr)
            }
        }
        
        self.collectionView.reloadData()
    }
    private func loadSnkrs() {
        self.snkrs = snkrService.loadAll()
    }
    
    private func pickRandomSnkr() -> Snkr {
        var unpickedSnkrs = [Snkr]()
        
        for snkr in snkrs {
            if snkr.lastWornDate == nil {
                unpickedSnkrs.append(snkr)
            }
        }
        
        if unpickedSnkrs.count == 0 {
            for snkr in snkrs {
                snkr.lastWornDate = nil
            }
            
            self.collectionView.reloadData()
            
            unpickedSnkrs = snkrs
        }
    
        return unpickedSnkrs[Int(arc4random_uniform(UInt32(unpickedSnkrs.count)))]
    }
    
    private func setTitle() {
           
           if (snkrs.count == 1) {
               self.title = String(format: "%d Snkr", snkrs.count)
           } else {
               self.title = String(format: "%d Snkrs", snkrs.count)
           }
       }
}

extension UIImage {
    func resized(toWidth width: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        let format = imageRendererFormat
        
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}

