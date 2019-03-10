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
    var snkrService = SnkrService()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSnkrs()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.backgroundColor = UIColor.lightGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dirtySnkrs.removeAll()
        loadSnkrs()
        reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dirtySnkrs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 325
    }

    override func viewDidAppear(_ animated: Bool) {
        reloadData()
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
    
    @IBAction func cleanAllSnkrs(_ sender: Any) {
        let dialogMessage = UIAlertController(title: AlertLabels.confirmTitle, message: AlertLabels.cleanAllMessage, preferredStyle: .alert)
        let noAction = UIAlertAction(title: ButtonLabels.no, style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: ButtonLabels.yes, style: .default, handler: { (action) -> Void in
            
            for snkr in self.dirtySnkrs {
                snkr.isClean = true
                self.snkrService.update(snkr: snkr)
            }
            
            self.dirtySnkrs.removeAll()
            self.reloadData()
        });
        
        dialogMessage.addAction(yesAction)
        dialogMessage.addAction(noAction)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func loadSnkrs() {
        dirtySnkrs = snkrService.loadAll(isClean: false)
    }
    
    private func markSnkrClean(cell: DirtySnkrViewCell) {
        let dialogMessage = UIAlertController(title: AlertLabels.confirmTitle, message: AlertLabels.cleanMessage, preferredStyle: .alert)
        let noAction = UIAlertAction(title: ButtonLabels.no, style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: ButtonLabels.yes, style: .default, handler: { (action) -> Void in
            let indexPath = cell.getIndexPath()
            let snkr = self.dirtySnkrs.remove(at: (indexPath?.row)!)
            snkr.isClean = true
            
            self.tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.automatic)
            self.snkrService.update(snkr: snkr)
        });
        
        dialogMessage.addAction(yesAction)
        dialogMessage.addAction(noAction)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func reloadData() {
        self.tableView.reloadData()
        
        if dirtySnkrs.isEmpty {
            let backgroundImage = UIImage(named: "icon-sponge.png")
            let imageView = UIImageView(image: backgroundImage)
            
            imageView.contentMode = .scaleAspectFit
            
            self.tableView.backgroundView = imageView
            self.tableView.backgroundColor = CellConstants.lightGray
        } else {
            self.tableView.backgroundView = nil
        }
    }
}
