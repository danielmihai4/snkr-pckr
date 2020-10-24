//
//  CategoryService.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CategoryService {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func loadAll() -> [Category] {
        var categories = [Category]()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CategoryEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            let categoryEntities = try context.fetch(request) as! [CategoryEntity]
            
            for categoryEntity in categoryEntities {
                let category = Category(id: categoryEntity.id!, name: categoryEntity.name!)
                
                for snkrEntity in categoryEntity.sneakers?.allObjects as! [SnkrEntity] {
                    let snkr = Snkr(
                        id: snkrEntity.id!,
                        name: snkrEntity.name!,
                        colorway: snkrEntity.colorway!,
                        lastWornDate: snkrEntity.lastWornDate,
                        isClean: snkrEntity.isClean,
                        pic: nil,
                        smallPic: UIImage(data: snkrEntity.smallPic!)!,
                        orderId: Int(snkrEntity.orderId))
                
                    category.snkrs.append(snkr)
                }
                
                categories.append(category)
            }
        } catch {
            print ("Cannot load categories")
        }
        
        return categories
    }
    
    func store(category: Category) {
        let categoryEntity = CategoryEntity(context: context)
        
        categoryEntity.id = category.id
        categoryEntity.name = category.name
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func delete(category: Category) {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let predicate = NSPredicate(format: "id=%@", category.id as CVarArg)
        
        request.predicate = predicate
        
        do {
            let categoryEntity = try context.fetch(request).first
            context.delete(categoryEntity!)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func addSnkr(category: Category, snkr: Snkr) {
        let categoryRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let categoryPredicate = NSPredicate(format: "id=%@", category.id as CVarArg)
        let snkrRequest: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let snkrPredicate = NSPredicate(format: "id=%@", snkr.id as CVarArg)
        
        categoryRequest.predicate = categoryPredicate
        snkrRequest.predicate = snkrPredicate
        
        do {
            let categoryEntity = try context.fetch(categoryRequest).first
            let snkrEntity = try context.fetch(snkrRequest).first
            
            categoryEntity?.addToSneakers(snkrEntity!)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func removeSnkr(category: Category, snkr: Snkr) {
        let categoryRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let categoryPredicate = NSPredicate(format: "id=%@", category.id as CVarArg)
        let snkrRequest: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let snkrPredicate = NSPredicate(format: "id=%@", snkr.id as CVarArg)
        
        categoryRequest.predicate = categoryPredicate
        snkrRequest.predicate = snkrPredicate
        
        do {
            let categoryEntity = try context.fetch(categoryRequest).first
            let snkrEntity = try context.fetch(snkrRequest).first
            
            categoryEntity?.removeFromSneakers(snkrEntity!)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
