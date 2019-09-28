//
//  DirtySnkrsTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 02/12/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit
import CoreData
import SwiftEntryKit

class DirtySnkrsTableViewController: UITableViewController, TableViewCellDelegate, ConfirmationPopupDelegate {
    
    var dirtySnkrs = [Snkr]()
    var snkrService = SnkrService()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadSnkrs()
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
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
        return 330
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
        
        if (dirtySnkrs.firstIndex{$0 === snkr} == 0) {
            cell.addTopBorder()
        }
        
        return cell
    }
    
    internal func doubleTap(cell: UITableViewCell) {
        if let dirtySnkrCell = cell as? DirtySnkrViewCell {
            class PopupDelegate: ConfirmationPopupDelegate {
                let parent: DirtySnkrsTableViewController
                let cell: DirtySnkrViewCell
                
                init(parent: DirtySnkrsTableViewController, cell: DirtySnkrViewCell) {
                    self.parent = parent
                    self.cell = cell
                }
                
                internal func performCancelAction() {
                    //nothing to do
                }
                
                internal func performConfirmAction() {
                    self.parent.markSnkrClean(self.cell)
                }
            }
            
            let confirmationPopup = ConfirmationPopup(title: PopUpLabels.confirmCleanSnkrPopupTitle, titleAlignment: NSTextAlignment.center, image: nil, delegate: PopupDelegate(parent: self, cell: dirtySnkrCell))
            
            SwiftEntryKit.display(entry: confirmationPopup.getContentView(), using: confirmationPopup.getAttributes())
        }
    }
    
    internal func performConfirmAction() {
        for snkr in self.dirtySnkrs {
            snkr.isClean = true
            self.snkrService.update(snkr: snkr)
        }
        
        self.dirtySnkrs.removeAll()
        self.reloadData()
    }
    
    internal func performCancelAction() {
        //nothing to do
    }
    
    @IBAction func cleanAllSnkrs(_ sender: Any) {
        let confirmationPopup = ConfirmationPopup(title: PopUpLabels.confirmCleanAllPopupTitle, titleAlignment: NSTextAlignment.center, image: nil, delegate: self)
        
        SwiftEntryKit.display(entry: confirmationPopup.getContentView(), using: confirmationPopup.getAttributes())
    }
    
    private func loadSnkrs() {
        dirtySnkrs = snkrService.loadAll(isClean: false)
    }
    
//    private func markSnkrClean(cell: DirtySnkrViewCell) {
//        let dialogMessage = UIAlertController(title: AlertLabels.confirmTitle, message: AlertLabels.cleanMessage, preferredStyle: .alert)
//        let noAction = UIAlertAction(title: ButtonLabels.no, style: .cancel, handler: nil)
//        let yesAction = UIAlertAction(title: ButtonLabels.yes, style: .default, handler: { (action) -> Void in
//            let indexPath = cell.getIndexPath()
//            let snkr = self.dirtySnkrs.remove(at: (indexPath?.row)!)
//            snkr.isClean = true
//
//            self.tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.automatic)
//            self.snkrService.update(snkr: snkr)
//        });
//
//        dialogMessage.addAction(yesAction)
//        dialogMessage.addAction(noAction)
//
//        self.present(dialogMessage, animated: true, completion: nil)
//    }
    
    private func markSnkrClean(_ cell: DirtySnkrViewCell) {
        let indexPath = cell.getIndexPath()
        let snkr = self.dirtySnkrs.remove(at: (indexPath?.row)!)
        snkr.isClean = true
        
        self.tableView.deleteRows(at: [indexPath!], with: UITableView.RowAnimation.automatic)
        self.snkrService.update(snkr: snkr)
    }
    
    private func reloadData() {
        self.tableView.reloadData()
        
        if dirtySnkrs.isEmpty {
            let imageView = UIImageView(image: UIImage(named: "icon-empty-box.png"))
            
            imageView.contentMode = .center
                        
            self.tableView.backgroundView = imageView            
        } else {
            self.tableView.backgroundView = nil
        }
    }
}
