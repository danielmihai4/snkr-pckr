//
//  DirtySnkrsTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 02/12/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit
import CoreData

class DirtySnkrsTableViewController: UITableViewController, TableViewCellDelegate {
    
    var dirtySnkrs = [Snkr]()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSnkrs()
        setTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dirtySnkrs.removeAll()
        loadSnkrs()
        self.tableView.reloadData()
        setTitle()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dirtySnkrs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 410
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.DirtySnkr, for: indexPath) as! DirtySnkrViewCell
        let snkr = dirtySnkrs[indexPath.row]
        
        cell.pic.image = snkr.pic
        cell.nameLabel.text = snkr.name
        cell.colorwayLabel.text = snkr.colorway
        cell.delegate = self
        
        return cell
    }
    
    internal func doubleTap(cell: UITableViewCell) {
        if let dirtySnkrCell = cell as? DirtySnkrViewCell {
            markSnkrClean(cell: dirtySnkrCell)
        }
    }
    
    private func setTitle() {
        if (dirtySnkrs.count == 1) {
            self.title = String(format: "%d Dirty Snkr", dirtySnkrs.count)
        } else {
            self.title = String(format: "%d Dirty Snkrs", dirtySnkrs.count)
        }
    }
    
    private func loadSnkrs() {
        let request: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "isClean == %@", NSNumber(value: false))
        
        request.predicate = predicate
        
        do {
            let snkrEntities = try context.fetch(request)
            
            for snkrEntity in snkrEntities {
                let dirtySnkr = Snkr(
                    name: snkrEntity.name!,
                    colorway: snkrEntity.colorway!,
                    lastWornDate: snkrEntity.lastWornDate,
                    isClean: snkrEntity.isClean,
                    pic: UIImage(data: snkrEntity.pic!)!)
                
                dirtySnkrs.append(dirtySnkr)
            }
        } catch {
            print ("Cannot load dirty snkrs.")
        }
    }
    
    private func updateSnkrEntity(snkr: Snkr) {
        let request: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "name=%@ AND colorway=%@", snkr.name, snkr.colorway)
        
        request.predicate = predicate
        
        do {
            let snkrEntities = try context.fetch(request)
            let snkrEntity = snkrEntities.first!
            
            snkrEntity.lastWornDate = snkr.lastWornDate
            snkrEntity.isClean = snkr.isClean!
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch let error {
            print (error.localizedDescription)
        }
    }
    
    private func markSnkrClean(cell: DirtySnkrViewCell) {
        let dialogMessage = UIAlertController(title: AlertLabels.confirmTitle, message: AlertLabels.cleanMessage, preferredStyle: .alert)
        let noAction = UIAlertAction(title: ButtonLabels.no, style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: ButtonLabels.yes, style: .default, handler: { (action) -> Void in
            let indexPath = cell.getIndexPath()
            let snkr = self.dirtySnkrs.remove(at: (indexPath?.row)!)
            snkr.isClean = true
            
            self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
            self.updateSnkrEntity(snkr: snkr)
            self.setTitle()
        });
        
        dialogMessage.addAction(yesAction)
        dialogMessage.addAction(noAction)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
}
