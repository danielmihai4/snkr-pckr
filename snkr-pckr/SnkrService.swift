//
//  SnkrService.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 24/02/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SnkrService {
    
    func loadAll(isClean: Bool) -> [Snkr] {
        var snkrs = [Snkr]()
        let request: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "isClean == %@", NSNumber(value: isClean))
        
        request.predicate = predicate
        
        do {
            let snkrEntities = try context.fetch(request)
            
            for snkrEntity in snkrEntities {
                let dirtySnkr = Snkr(
                    id: snkrEntity.id!,
                    name: snkrEntity.name!,
                    colorway: snkrEntity.colorway!,
                    lastWornDate: snkrEntity.lastWornDate,
                    isClean: snkrEntity.isClean,
                    pic: nil,
                    smallPic: (snkrEntity.smallPic != nil) ? UIImage(data: snkrEntity.smallPic!)! : nil)
                
                snkrs.append(dirtySnkr)
            }
        } catch {
            print ("Cannot load dirty snkrs.")
        }
        
        return snkrs
    }
    
    func loadAll() -> [Snkr] {
        var snkrs = [Snkr]()
        var snkrEntities = [SnkrEntity]()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SnkrEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            snkrEntities = try context.fetch(request) as! [SnkrEntity]
            
            for snkrEntity in snkrEntities {
                let snkr = Snkr(
                    id: snkrEntity.id!,
                    name: snkrEntity.name!,
                    colorway: snkrEntity.colorway!,
                    lastWornDate: snkrEntity.lastWornDate,
                    isClean: snkrEntity.isClean,
                    pic: nil,
                    smallPic: (snkrEntity.smallPic != nil) ? UIImage(data: snkrEntity.smallPic!)! : nil)
                
                snkrs.append(snkr)
            }
        } catch {
            print ("Cannot load snkrs")
        }
        
        return snkrs
    }
    
   func store(snkr: Snkr) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let snkrEntity = SnkrEntity(context: context)
        
        snkrEntity.id = snkr.id
        snkrEntity.name = snkr.name
        snkrEntity.colorway = snkr.colorway
        snkrEntity.lastWornDate = snkr.lastWornDate
        snkrEntity.isClean = snkr.isClean!
        snkrEntity.pic = snkr.pic!.jpegData(compressionQuality: 1)
        snkrEntity.smallPic = snkr.smallPic!.jpegData(compressionQuality: 1)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func update(snkr: Snkr) {
        let request: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "id=%@", snkr.id as CVarArg)
        
        request.predicate = predicate
        
        do {
            let snkrEntities = try context.fetch(request)
            let snkrEntity = snkrEntities.first!
            
            snkrEntity.name = snkr.name
            snkrEntity.colorway = snkr.colorway
            snkrEntity.lastWornDate = snkr.lastWornDate
            snkrEntity.isClean = snkr.isClean!
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch let error {
            print (error.localizedDescription)
        }
    }
    
    func delete(snkr: Snkr) {
        let request: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "id=%@", snkr.id as CVarArg)
        
        request.predicate = predicate
        
        do {
            let snkrEntities = try context.fetch(request)
            
            for snkrEntity in snkrEntities {
                context.delete(snkrEntity)
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func loadPic(snkr: Snkr) -> UIImage? {
        let request: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "id=%@", snkr.id as CVarArg)
        
        request.predicate = predicate
        
        do {
            let snkrEntities = try context.fetch(request)
            let snkrEntity = snkrEntities.first!
            
            return (snkrEntity.pic != nil) ? UIImage(data: snkrEntity.pic!)! : nil
        } catch let error {
            print (error.localizedDescription)
        }
        
        return nil
    }
}
