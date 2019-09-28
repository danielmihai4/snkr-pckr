//
//  CategorySnkrsViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 10/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class CategorySnkrsModalViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    var category: Category? = nil
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var tableView: CategorySnkrsTableView!
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryNameLabel.text = category?.name
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (category?.snkrs.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.CategorySnkr , for: indexPath) as! CategorySnkrCell
        let snkr = self.category?.snkrs[indexPath.row]
        
        cell.nameLabel.text = snkr?.name
        cell.colorwayLabel.text = snkr?.colorway
        cell.pic.image = snkr?.pic
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if (self.category?.snkrs.firstIndex{$0 === snkr} == 0) {
            cell.addTopBorder()
        }
        
        return cell
    }
    
}
