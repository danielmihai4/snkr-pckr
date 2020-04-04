//
//  SnkrSelectorTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 10/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class SnkrSelectorTableViewController: UITableViewController, TableViewCellDelegate {

    var snkrs = [Snkr]()
    var snkrService = SnkrService()
    var category: Category? = nil
    var categoryService = CategoryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        snkrs = snkrService.loadAll()
        
        self.title = category?.name
        self.tableView.separatorStyle = .none
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snkrs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 138
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.SnkrSelector, for: indexPath) as! SnkrSelectorCell
        let snkr = snkrs[indexPath.row]
        
        cell.pic.image = snkr.pic
        cell.nameLabel.text = snkr.name
        cell.colorwayLabel.text = snkr.colorway
        cell.delegate = self
        cell.selectionStyle = .none
        
        let categoryHasSnkr = category?.snkrs.contains {$0.id == snkr.id}
        if categoryHasSnkr != nil && (categoryHasSnkr)! {
            cell.checkbox.image = UIImage(named: "icon-checkbox-selected.png")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        } else {
            cell.checkbox.image = UIImage(named: "icon-checkbox-unselected.png")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        }
        cell.checkbox.tintColor = Colors.dustStorm
        
        if (snkrs.firstIndex{$0 === snkr} == 0) {
            cell.addTopBorder()
        }
        
        return cell
    }
    
    internal func doubleTap(cell: UITableViewCell) {
        if let snkrSelectorCell = cell as? SnkrSelectorCell {
            toggleSnkr(cell: snkrSelectorCell)
        }
    }
    
    private func toggleSnkr(cell: SnkrSelectorCell) {
        let indexPath = cell.getIndexPath()
        let snkr = snkrs[(indexPath?.row)!]
        let categoryHasSnkr = category?.snkrs.contains { (element) in
            return snkr.id == element.id
        };
        
        if categoryHasSnkr != nil && (categoryHasSnkr)! {
            cell.checkbox.image = UIImage(named: "icon-checkbox-unselected.png")
            
            let index = category?.snkrs.firstIndex {$0.id == snkr.id}
            category?.snkrs.remove(at: index!)
            categoryService.removeSnkr(category: category!, snkr: snkr)
        } else {
            cell.checkbox.image = UIImage(named: "icon-checkbox-selected.png")
            
            category?.snkrs.append(snkr)
            categoryService.addSnkr(category: category!, snkr: snkr)
        }
        
    }
}
