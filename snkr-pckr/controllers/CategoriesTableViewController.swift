//
//  CategoriesTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

class CategoriesTableViewController: UITableViewController, NewCategoryPopupDelegate {
    
    var categories = [Category]()
    var categoryService = CategoryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categories = categoryService.loadAll()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let category = self.categories[indexPath.row]
            
            self.categoryService.delete(category: category)
            self.categories.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ShowSnkrSelector {
            let destination = segue.destination as! SnkrSelectorTableViewController
            let buttonPosition = (sender as! UIButton).convert(CGPoint(), to:tableView)
            let indexPath = tableView.indexPathForRow(at:buttonPosition)
            
            destination.category = categories[(indexPath?.row)!]
        } else if segue.identifier == Segues.ShowCategorySnkrs {
            let destination = segue.destination as! CategorySnkrsModalViewController
            let indexPath = tableView.indexPathForSelectedRow
            
            destination.category = categories[(indexPath?.row)!]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Category, for: indexPath) as! CategoryViewCell
        let category = categories[indexPath.row]
        
        cell.nameLabel.text = category.name
        cell.snkrCountLabel.text = displaySnkrCount(snkrCount: category.snkrs.count)
        
        if (categories.firstIndex{$0 === category} == 0) {
            cell.addTopBorder()
        }
        
        return cell
    }
    
    internal func saveNewCategory(name: String) {
        let category = Category(id: UUID(), name: name)
        
        categoryService.store(category: category)
        categories.append(category)
        tableView.reloadData()
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let newCategoryPopup = NewCategoryPopup(self)
        
        SwiftEntryKit.display(entry: newCategoryPopup.getContentView(), using: newCategoryPopup.getAttributes(), presentInsideKeyWindow: true)
    }
    
    @IBAction func backToCategories(segue:UIStoryboardSegue) {
        //nothing to do.
    }
    
    private func displaySnkrCount(snkrCount: Int) -> String {
        if snkrCount == 0 {
            return CellLabels.noSnkrsSelected
        }
        
        return "\(snkrCount) snkrs."
    }
}
