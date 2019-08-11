//
//  CategorySnkrsDataSource.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 11/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class CategorySnkrsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var snkrs = [Snkr]()
    
    init(_ snkrs: [Snkr]) {
        self.snkrs = snkrs
    }
    
    func setData(_ snkrs: [Snkr]) {
        self.snkrs = snkrs
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.snkrs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.CategorySnkr, for: indexPath) as! CategorySnkrCell
        
        return cell
    }
    
    func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as CategorySnkrCell = cell else {
            return
        }
        
        let snkr = snkrs[indexPath.row]
        
        cell.pic.image = snkr.pic
        cell.nameLabel.text = snkr.name
        cell.colorwayLabel.text = snkr.colorway
        cell.layoutIfNeeded()
    }    
}
