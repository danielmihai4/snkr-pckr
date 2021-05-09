//
//  CategoriesTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

class CategoriesTableViewController: UITableViewController, NewCategoryPopupDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CategoryOptionsPopupViewDelegate, ConfirmationPopupDelegate {
    
    var categories = [Category]()
    var categoryService = CategoryService()
    var categoryToDelete: Category?
    
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
        return 260
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ShowSnkrSelector {
            let destination = segue.destination as! SnkrSelectorCollectionViewController

            destination.category = sender as? Category
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CategoryViewCell else { return }
        
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Category, for: indexPath) as! CategoryViewCell
        let category = categories[indexPath.row]
        
        cell.nameLabel.text = category.name
        cell.snkrCountLabel.text = displaySnkrCount(snkrCount: category.snkrs.count)
        cell.optionsButton.addTarget(self, action: #selector(optionsButtonPressed(sender:)), for: .touchUpInside)
        
        if (categories.firstIndex{$0 === category} == 0) {
            cell.addTopBorder()
        }
        
        return cell
    }
    
    @objc func optionsButtonPressed(sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint(), to: tableView)
        let indexPath = tableView.indexPathForRow(at:buttonPosition)
        let category = categories[indexPath!.row]
        let contentView = CategoryOptionsPopupView(delegate: self, category: category)
        
        SwiftEntryKit.display(entry: contentView, using: contentView.getAttributes(), presentInsideKeyWindow: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories[collectionView.tag].snkrs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cells.SnkrCategoryCollectionViewCell, for: indexPath) as! SnkrCategoryCollectionViewCell
        let category = categories[collectionView.tag]
        let snkrs = category.snkrs
        let snkr = snkrs[indexPath.row]
        
        cell.configure(snkr: snkr)
        
        return cell
    }
    
    func selectSnkrs(_ category: Category) {
        performSegue(withIdentifier: Segues.ShowSnkrSelector, sender: category)
    }
    
    func deleteCategory(_ category: Category) {
        self.categoryToDelete = category
        
        let confirmationPopup = ConfirmationPopup(title: PopUpLabels.confirmDeleteSnkrPopupTitle, image: nil, delegate: self)
        
        SwiftEntryKit.display(entry: confirmationPopup.getContentView(), using: confirmationPopup.getAttributes())
    }
    
    func performConfirmAction() {
        let index = self.categories.firstIndex{$0 === self.categoryToDelete}
        let indexPath = IndexPath(row: index!, section: 0)
        
        self.categoryService.delete(category: self.categoryToDelete!)
        self.categories.remove(at: indexPath.row)
        self.tableView.reloadData()
    }
    
    func performCancelAction() {
        self.categoryToDelete = nil
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
