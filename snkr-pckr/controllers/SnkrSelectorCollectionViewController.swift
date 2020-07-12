//
//  SnkrSelectorCollectionViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 28/06/2020.
//  Copyright © 2020 Daniel Mihai. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SnkrSelectorCollectionViewController: UICollectionViewController, CollectionViewCellDelegate {
    
    var snkrs = [Snkr]()
    var snkrService = SnkrService()
    var category: Category? = nil
    var categoryService = CategoryService()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        snkrs = snkrService.loadAll()
        self.title = category?.name
        self.collectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snkrs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = UICollectionViewCell()
        if let snkrSelectorCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.SnkrSelectorCollectionCell, for: indexPath) as? SnkrSelectorCollectionViewCell {
            let snkr = snkrs[indexPath.row]
            let stateImage: UIImage?
            let categoryHasSnkr = category?.snkrs.contains {$0.id == snkr.id}
            if categoryHasSnkr != nil && (categoryHasSnkr)! {
                stateImage = UIImage(named: "icon-checkbox-selected.png")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            } else {
                stateImage = UIImage(named: "icon-checkbox-unselected.png")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            }
            
            snkrSelectorCollectionCell.configure(snkr: snkr, stateImage: stateImage!)
            snkrSelectorCollectionCell.delegate = self
            snkrSelectorCollectionCell.layer.borderColor = Colors.dustStorm.cgColor
            snkrSelectorCollectionCell.layer.borderWidth = 1
              
            cell = snkrSelectorCollectionCell
          }
          
          return cell
    }
    
    internal func doubleTap(cell: UICollectionViewCell) {
        if let snkrSelectorCell = cell as? SnkrSelectorCollectionViewCell {
            toggleSnkr(cell: snkrSelectorCell)
        }
    }
    
    private func toggleSnkr(cell: SnkrSelectorCollectionViewCell) {
        let indexPath = cell.getIndexPath()
        let snkr = snkrs[(indexPath?.row)!]
        let categoryHasSnkr = category?.snkrs.contains { (element) in
            return snkr.id == element.id
        }

        if categoryHasSnkr != nil && (categoryHasSnkr)! {
            cell.stateImageView.image = UIImage(named: "icon-checkbox-unselected.png")

            let index = category?.snkrs.firstIndex {$0.id == snkr.id}
            category?.snkrs.remove(at: index!)
            categoryService.removeSnkr(category: category!, snkr: snkr)
        } else {
            cell.stateImageView.image = UIImage(named: "icon-checkbox-selected.png")

            category?.snkrs.append(snkr)
            categoryService.addSnkr(category: category!, snkr: snkr)
        }

    }
}
