//
//  CategoriesTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {
    
    var categories = [Category]()
    var categoryService = CategoryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categories = categoryService.loadAll()
        
        tableView.separatorStyle = .none
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
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

        return cell
    }
    
    @IBAction func addCategory(_ sender: Any) {
        let alert = UIAlertController(title: AlertLabels.newCategoryTitle, message: nil, preferredStyle: .alert);
        
        let cancelAction = UIAlertAction(title: AlertLabels.newCategoryCancelActionName, style: .cancel);
        let saveAction = UIAlertAction(title: AlertLabels.newCategorySaveActionName, style: .destructive, handler: { (action) -> Void in
            guard let textField = alert.textFields?.first else {
                print ("Cannot retrieve alert text field.")
                return;
            }
            
            self.saveCategory(name: textField.text!)
        });
        
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = AlertLabels.newCategoryPlaceholder
            textField.keyboardType = UIKeyboardType.default
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func displaySnkrCount(snkrCount: Int) -> String {
        if snkrCount == 0 {
            return CellLabels.noSnkrsSelected
        }
        
        return "\(snkrCount) snkrs."
    }
    
    private func saveCategory(name: String) {
        let category = Category(id: UUID(), name: name)
        
        categoryService.store(category: category)
        categories.append(category)
        tableView.reloadData()
    }
}
