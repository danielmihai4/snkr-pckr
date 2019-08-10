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
        
        loadWishlistItems()        
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let wishlistItem = self.wishlistItems[indexPath.row]
            
            self.wishlistItemService.delete(wishlistItem: wishlistItem)
            self.wishlistItems.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.WishlistItemCell, for: indexPath) as! WishlistItemTableViewCell
        let wishlistItem = wishlistItems[indexPath.row]
        
        cell.nameLabel.text = wishlistItem.name
        cell.colorwayLabel.text = wishlistItem.colorway
        cell.priceLabel.text = formatPrice(wishlistItem.price)
        cell.releaseDateDayLabel.text = DateUtils.formatReleaseDateDay(releaseDate: wishlistItem.releaseDate)
        cell.releaseDateMonthLabel.text = DateUtils.formatReleaseDateMonth(releaseDate: wishlistItem.releaseDate)
        cell.pic.image = wishlistItem.pic
        
        return cell
    }
    
    @IBAction func saveWishlistItem(segue:UIStoryboardSegue) {
        if let source = segue.source as? NewWishlistItemViewController {
            let resizedPicture = cropAndScaleImage(scrollView: source.scrollView)
            
            let wishlistItem = WishlistItem(
                id: UUID(),
                name: source.nameTextField.text!,
                colorway: source.colorwayTextField.text!,
                price: parsePrice(source.priceTextField.text!),
                releaseDate: DateUtils.parseReleaseDate(releaseDate: source.releaseDateTextField.text!),
                pic: resizedPicture)
            
            addAndSortWishlistItems(wishlistItem)
            
            wishlistItemService.store(wishlistItem: wishlistItem)
        }
    }
    
    private func loadWishlistItems() {
        self.wishlistItems = wishlistItemService.loadAll()
        self.wishlistItems.sort {
            $0.releaseDate < $1.releaseDate
        }
    }
    
    private func addAndSortWishlistItems(_ wishlistItem: WishlistItem) {
        self.wishlistItems.append(wishlistItem)
        self.wishlistItems.sort {
            $0.releaseDate < $1.releaseDate
        }
    }
    
    private func formatPrice(_ price: NSDecimalNumber) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "en_GB")
        
        return numberFormatter.string(from: price)!
    }
    
    private func parsePrice(_ price: String) -> NSDecimalNumber {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        
        return formatter.number(from: price) as? NSDecimalNumber ?? 0
    }
    
    private func cropAndScaleImage(scrollView: UIScrollView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(scrollView.bounds.size, true, UIScreen.main.scale)
        
        let offset = scrollView.contentOffset
        
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let pictureToSave = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return pictureToSave!
    }
}
