//
//  WishlistItemService.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 21/07/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class WishlistItemService {
    
    func loadAll() -> [WishlistItem] {
        var wishlistItems = [WishlistItem]()
        var wishlistItemEntities = [WishlistItemEntity]()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "WishlistItemEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            wishlistItemEntities = try context.fetch(request) as! [WishlistItemEntity]
            
            for wishlistItemEntity in wishlistItemEntities {
                let wishlistItem = WishlistItem(
                    id: wishlistItemEntity.id!,
                    name: wishlistItemEntity.name!,
                    colorway: wishlistItemEntity.colorway!,
                    price: wishlistItemEntity.price!,
                    releaseDate: wishlistItemEntity.releaseDate!,
                    pic: UIImage(data: wishlistItemEntity.pic!)!)
                
                wishlistItems.append(wishlistItem)
            }
        } catch {
            NSLog("Cannot load wishlist items!")
        }
        
        return wishlistItems
    }
    
    func store(wishlistItem: WishlistItem) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let wishlistItemEntity = WishlistItemEntity(context: context)
        
        wishlistItemEntity.id = wishlistItem.id
        wishlistItemEntity.name = wishlistItem.name
        wishlistItemEntity.colorway = wishlistItem.colorway
        wishlistItemEntity.price = wishlistItem.price
        wishlistItemEntity.releaseDate = wishlistItem.releaseDate
        wishlistItemEntity.pic = UIImageJPEGRepresentation(wishlistItem.pic, 1)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func delete(wishlistItem: WishlistItem) {
        let request: NSFetchRequest<WishlistItemEntity> = WishlistItemEntity.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "id=%@", wishlistItem.id as CVarArg)
        
        request.predicate = predicate
        
        do {
            let wishlistItemEntities = try context.fetch(request)
            
            for wishlistItemEntity in wishlistItemEntities {
                context.delete(wishlistItemEntity)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
            
        } catch let error {
            NSLog(error.localizedDescription)
        }
    }
}
