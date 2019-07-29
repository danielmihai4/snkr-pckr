//
//  WishlistTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 21/07/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class WishlistTableViewController: UITableViewController {

    var wishlistItems = [WishlistItem]()
    var wishlistItemService = WishlistItemService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.wishlistItems = wishlistItemService.loadAll()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let releaseDate = formatter.date(from: "01/08/2019")
        wishlistItems.append(WishlistItem(id: UUID(), name: "Air Jordan 4", colorway: "Cool Grey", price: 165, releaseDate: releaseDate!, pic: UIImage(named: "jordan-4")!))
        
        let releaseDate2 = formatter.date(from: "11/12/2019")
        wishlistItems.append(WishlistItem(id: UUID(), name: "Air Jordan 11", colorway: "Bred", price: 165, releaseDate: releaseDate2!, pic: UIImage(named: "jordan-11")!))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.wishlistItems.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let wishlistItem = self.wishlistItems[indexPath.row]
            
            self.wishlistItemService.delete(wishlistItem: wishlistItem)
            self.wishlistItems.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.WishlistItemCell, for: indexPath) as! WishlistItemTableViewCell
        let wishlistItem = wishlistItems[indexPath.row]
        
        cell.nameLabel.text = wishlistItem.name
        cell.colorwayLabel.text = wishlistItem.colorway
        cell.priceLabel.text = formatPrice(price: wishlistItem.price)
        cell.releaseDateDayLabel.text = DateUtils.formatReleaseDateDay(releaseDate: wishlistItem.releaseDate)
        cell.releaseDateMonthLabel.text = DateUtils.formatReleaseDateMonth(releaseDate: wishlistItem.releaseDate)
        cell.pic.image = wishlistItem.pic
        
        return cell
    }
    
    private func formatPrice(price: NSDecimalNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_GB")
        
        return numberFormatter.string(from: price)!
    }
}
