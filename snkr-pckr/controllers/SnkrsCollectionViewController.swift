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

class SnkrsCollectionViewController: UICollectionViewController, UISearchBarDelegate, CollectionViewCellDelegate, PopUpOptionsControlleDelegate, ConfirmationPopupDelegate, PickedSnkrModalViewControllerDelegate {
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    
    var filteredSnkrs = [Snkr]()
    var snkrs = [Snkr]() {
        didSet {
            self.setTitle()
            self.filteredSnkrs = snkrs
        }
    }
    
    var snkrService = SnkrService()
    var snkrToView: Snkr?
    var snkrToEdit: Snkr?
    var snkrToDelete: Snkr?
    var searchInProgress = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadSnkrs()
        self.collectionView.reloadData()
        self.setLongGestureRecognizer()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredSnkrs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let snkrCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.SnkrCollectionCell, for: indexPath) as? SnkrCollectionViewCell {
            snkrCollectionCell.configure(snkr: self.filteredSnkrs[indexPath.row])
            snkrCollectionCell.delegate = self
            
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SnkrCollectionViewHeader", for: indexPath)

            return headerView
         }

         return UICollectionReusableView()
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if sourceIndexPath.item < destinationIndexPath.item {
            for i in sourceIndexPath.item + 1 ... destinationIndexPath.item {
                self.snkrs[i].orderId -= 1
            }
            self.snkrs[sourceIndexPath.item].orderId = self.snkrs[destinationIndexPath.item].orderId + 1
        } else {
            for i in destinationIndexPath.item ... sourceIndexPath.item - 1 {
                self.snkrs[i].orderId += 1
            }
            self.snkrs[sourceIndexPath.item].orderId = self.snkrs[destinationIndexPath.item].orderId - 1
        }
            
        self.snkrs.sort { $0.orderId < $1.orderId }
        
        for snkr in self.snkrs {
            self.snkrService.update(snkr: snkr)
        }
        
        self.collectionView.reloadData()
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
                    pic: source.imageView.image!.resized(toWidth: 1080),
                    smallPic: source.imageView.image!.resized(toWidth: 540),
                    orderId: getNextOrderId())
                
                self.snkrs.append(snkr)
                self.collectionView.reloadData()
                        
                self.snkrService.store(snkr: snkr)
            }
        }
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            self.collectionView.endInteractiveMovement()
        default:
            self.collectionView.cancelInteractiveMovement()
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
    
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            let searchText = searchBar.text!.lowercased()
            self.filteredSnkrs = self.snkrs.filter{ $0.name.lowercased().contains(searchText) || $0.colorway.lowercased().contains(searchText) }
            
            self.searchInProgress = true
            self.collectionView?.reloadData()
        }
    }

    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            self.filteredSnkrs = self.snkrs
            self.searchInProgress = false
            self.collectionView?.reloadData()
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
       
       let confirmationPopup = ConfirmationPopup(title: PopUpLabels.confirmDeleteSnkrPopupTitle, image: snkr.smallPic, delegate: self)
       
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
    
    private func setLongGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        
        self.collectionView.addGestureRecognizer(longPressGesture)
    }
    
    private func getNextOrderId() -> Int {
        if self.snkrs.count == 0 {
            return 0
        }
        
        return self.snkrs[self.snkrs.count - 1].orderId + 1
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
