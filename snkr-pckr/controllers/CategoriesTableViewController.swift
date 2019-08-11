//
//  CategoriesTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

class CategoriesTableViewController: UITableViewController, NewCategoryPopupDelegate, CategoryViewCellDelegate, CategoryOptionsPopupViewDelegate, ConfirmationPopupDelegate {
    
    enum Const {
        static let closeCellHeight: CGFloat = 110
        static let openCellHeight: CGFloat = 210
    }
    
    var cellHeights: [CGFloat] = []
    
    var categories = [Category]()
    var categoryService = CategoryService()
    var categoryToDelete: Category?
    var categoryToEdit: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categories = categoryService.loadAll()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reload()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as CategoryViewCell = cell else {
            return
        }
        
        if cellHeights[indexPath.row] == Const.closeCellHeight {
            cell.unfold(false, animated: false, completion: nil)            
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        
        let category = categories[indexPath.row]
        let datasource = createCategorySnkrsDataSource(category)
        
        cell.delegate = self
        cell.categoryNameLabel.text = category.name
        cell.noSnkrsLabel.text = displaySnkrCount(snkrCount: category.snkrs.count)
        cell.unfoldedCategoryNameLabel.text = category.name
        cell.tableView.dataSource = datasource
        cell.tableView.delegate = datasource
        cell.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Category, for: indexPath) as! CategoryViewCell
        let durations: [TimeInterval] = [0.26, 0.2, 0.2]
        let category = categories[indexPath.row]
        let datasource = createCategorySnkrsDataSource(category)
        
        cell.tableView.dataSource = datasource
        cell.tableView.delegate = datasource
        cell.durationsForExpandedState = durations
        cell.durationsForCollapsedState = durations
        
        return cell
    }
    
    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CategoryViewCell
        
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == Const.closeCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = Const.openCellHeight
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = Const.closeCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 0.5
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            
            // fix https://github.com/Ramotion/folding-cell/issues/169
            if cell.frame.maxY > tableView.frame.maxY {
                tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ShowSnkrSelector {
            let destination = segue.destination as! SnkrSelectorTableViewController
            
            destination.category = categoryToEdit
        }
    }
    
    internal func saveNewCategory(name: String) {
        let category = Category(id: UUID(), name: name)
        
        categoryService.store(category: category)
        categories.append(category)
        reload()
    }
    
    internal func showOptions(for cell: CategoryViewCell) {
        let category = categories[(cell.getIndexPath()?.row)!]
        let categoryOptionsPopup = CategoryOptionsPopupView(with: self, category: category)
        
        SwiftEntryKit.display(entry: categoryOptionsPopup, using: categoryOptionsPopup.getAttributes(), presentInsideKeyWindow: true)
    }
    
    internal func editCategory(_ category: Category) {
        categoryToEdit = category
        performSegue(withIdentifier: Segues.ShowSnkrSelector, sender: self)
    }
    
    internal func deleteCategory(_ category: Category) {
        categoryToDelete = category
        let confirmationPopup = ConfirmationPopup(title: PopUpLabels.confirmCategorySnkrPopupTitle, image: nil, delegate: self)
        
        SwiftEntryKit.display(entry: confirmationPopup.getContentView(), using: confirmationPopup.getAttributes())
    }
    
    func performCancelAction() {
        categoryToDelete = nil
    }
    
    func performConfirmAction() {
        let index = self.categories.firstIndex{$0 === categoryToDelete}
        let indexPath = IndexPath(row: index!, section: 0)
        
        self.categories.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        self.categoryService.delete(category: categoryToDelete!)
        reload()
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let newCategoryPopup = NewCategoryPopup(self)
        
        SwiftEntryKit.display(entry: newCategoryPopup.getContentView(), using: newCategoryPopup.getAttributes(), presentInsideKeyWindow: true)
    }
    
    private func displaySnkrCount(snkrCount: Int) -> String {
        if snkrCount == 0 {
            return CellLabels.noSnkrsSelected
        }
        
        return "\(snkrCount) snkrs."
    }
    
    private func setup() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: categories.count)
        
        self.tableView.estimatedRowHeight = Const.closeCellHeight
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func reload() {
        cellHeights = Array(repeating: Const.closeCellHeight, count: categories.count)
        
        self.tableView.reloadData()
    }
    
    private func createCategorySnkrsDataSource(_ category: Category) -> CategorySnkrsDataSource {
        return CategorySnkrsDataSource(category.snkrs)
    }
}
