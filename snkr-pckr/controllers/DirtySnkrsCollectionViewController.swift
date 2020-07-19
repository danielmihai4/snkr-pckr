//
//  DirtySnkrsCollectionViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 28/06/2020.
//  Copyright © 2020 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

class DirtySnkrsCollectionViewController: UICollectionViewController, CollectionViewCellDelegate, ConfirmationPopupDelegate {
    
    var dirtySnkrs = [Snkr]()
    var snkrService = SnkrService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadSnkrs()
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dirtySnkrs.removeAll()
        loadSnkrs()
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dirtySnkrs.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let dirtySnkrCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.DirtySnkrCollectionCell, for: indexPath) as? DirtySnkrCollectionViewCell {
            dirtySnkrCollectionCell.configure(snkr: dirtySnkrs[indexPath.row])
            dirtySnkrCollectionCell.delegate = self
            
            cell = dirtySnkrCollectionCell
        }
        
        return cell
    }

    
    @IBAction func cleanAllSnkrs(_ sender: Any) {
        let confirmationPopup = ConfirmationPopup(title: PopUpLabels.confirmCleanAllPopupTitle, titleAlignment: NSTextAlignment.center, image: nil, delegate: self)
        
        SwiftEntryKit.display(entry: confirmationPopup.getContentView(), using: confirmationPopup.getAttributes())
    }
    
    internal func doubleTap(cell: UICollectionViewCell) {
        if let dirtySnkrCell = cell as? DirtySnkrCollectionViewCell {
            class PopupDelegate: ConfirmationPopupDelegate {
                let parent: DirtySnkrsCollectionViewController
                let cell: DirtySnkrCollectionViewCell
                
                init(parent: DirtySnkrsCollectionViewController, cell: DirtySnkrCollectionViewCell) {
                    self.parent = parent
                    self.cell = cell
                }
                
                internal func performCancelAction() {
                    //nothing to do
                }
                
                internal func performConfirmAction() {
                    self.parent.markSnkrClean(self.cell)
                }
            }
            
            let confirmationPopup = ConfirmationPopup(title: PopUpLabels.confirmCleanSnkrPopupTitle, titleAlignment: NSTextAlignment.center, image: nil, delegate: PopupDelegate(parent: self, cell: dirtySnkrCell))
            
            SwiftEntryKit.display(entry: confirmationPopup.getContentView(), using: confirmationPopup.getAttributes())
        }
    }
    
    internal func performConfirmAction() {
        for snkr in self.dirtySnkrs {
            snkr.isClean = true
            self.snkrService.update(snkr: snkr)
        }
        
        self.dirtySnkrs.removeAll()
        self.collectionView.reloadData()
    }
    
    internal func performCancelAction() {
        //nothing to do
    }
    
    private func markSnkrClean(_ cell: DirtySnkrCollectionViewCell) {
        let indexPath = cell.getIndexPath()
        let snkr = self.dirtySnkrs.remove(at: (indexPath?.row)!)
        snkr.isClean = true
        
        self.collectionView.deleteItems(at: [indexPath!])
        self.snkrService.update(snkr: snkr)
    }
    
    private func loadSnkrs() {
        dirtySnkrs = snkrService.loadAll(isClean: false)
    }
}
