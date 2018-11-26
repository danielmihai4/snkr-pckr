//
//  SnkrsTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 17/11/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit
import CoreData

class SnkrsTableViewController: UITableViewController, ModalViewControllerDelegate {
    
    var snkrs = [Snkr]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSnkrs()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snkrs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 193
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Snkr, for: indexPath) as! SnkrTableViewCell
        let snkr = snkrs[indexPath.row]
        
        cell.pic.image = snkr.pic
        cell.nameLabel.text = snkr.name
        cell.lastWornLabel.text = formatDate(lastWornDate: snkr.lastWornDate)
        cell.colorwayLabel.text = snkr.colorway
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            deleteSnkr(indexPath: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeAction = UIContextualAction(style: .normal, title:  "Pick", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.toggleWearState(indexPath: indexPath)
        })
        closeAction.image = UIImage(named: "icon-wear-sneaker")
        closeAction.backgroundColor = getColor(indexPath: indexPath)
        closeAction.title = getTitle(indexPath: indexPath)
        
        return UISwipeActionsConfiguration(actions: [closeAction])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Segues.ShowPickedSnkr {
                if let viewController = segue.destination as? ModalViewController {
                    viewController.delegate = self
                    viewController.modalPresentationStyle = .overFullScreen
                    viewController.snkr = pickRandomSnkr()
                }
            }
        }
    }
    
    @IBAction func saveSnkr(segue:UIStoryboardSegue) {
        if let source = segue.source as? NewSnkrViewController {
            let resizedPicture = cropAndScaleImage(scrollView: source.scrollView)
            
            let snkr = Snkr(
                name: source.nameTextField.text!,
                colorway: source.colorwayTextField.text!,
                lastWornDate: nil,
                pic: resizedPicture)
            
            snkrs.append(snkr)
            
            storeSnkrEntity(snkr: snkr)
        }
    }
    
    @IBAction func pickSnkr(_ sender: Any) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        
        self.overlayBlurredBackgroundView()
    }
    
    private func getColor(indexPath: IndexPath) -> UIColor {
        let snkr = self.snkrs[indexPath.row]
        
        return snkr.lastWornDate != nil ? .purple : .green
    }
    
    private func getTitle(indexPath: IndexPath) -> String {
        let snkr = self.snkrs[indexPath.row]
        
        return snkr.lastWornDate != nil ? "" : "Pick"
    }
    
    private func toggleWearState(indexPath: IndexPath) {
        let snkr = self.snkrs[indexPath.row]
        
        if snkr.lastWornDate != nil {
            snkr.lastWornDate = nil
        } else {
            snkr.lastWornDate = Date()
        }
        
        self.tableView.reloadData()
    }
    
    private func deleteSnkr(indexPath: IndexPath) {
        let dialogMessage = UIAlertController(title: AlertLabels.confirmTitle, message: AlertLabels.deleteMessage, preferredStyle: .alert)
        let cancel = UIAlertAction(title: ButtonLabels.cancel, style: .cancel, handler: nil)
        let ok = UIAlertAction(title: ButtonLabels.ok, style: .default, handler: { (action) -> Void in
            let snkr = self.snkrs.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            self.deleteSnkrEntity(snkr: snkr)
        });
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    private func formatDate(lastWornDate: Date?) -> String {
        if lastWornDate == nil {
            return "Not worn yet."
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        return formatter.string(from: lastWornDate!)
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
    
    private func loadSnkrs() {
        var snkrEntities = [SnkrEntity]()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SnkrEntity")
        request.returnsObjectsAsFaults = false
        
        do {
            snkrEntities = try context.fetch(request) as! [SnkrEntity]
            
            for snkrEntity in snkrEntities {
                let snkr = Snkr(
                    name: snkrEntity.name!,
                    colorway: snkrEntity.colorway!,
                    lastWornDate: snkrEntity.lastWornDate,
                    pic: UIImage(data: snkrEntity.pic!)!)
                
                snkrs.append(snkr)
            }
            
        } catch {
            print ("Cannot load snkrs")
        }
    }
    
    private func storeSnkrEntity(snkr: Snkr) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let snkrEntity = SnkrEntity(context: context)
        
        snkrEntity.name = snkr.name
        snkrEntity.colorway = snkr.colorway
        snkrEntity.lastWornDate = snkr.lastWornDate
        snkrEntity.pic = UIImageJPEGRepresentation(snkr.pic, 1)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    private func deleteSnkrEntity(snkr: Snkr) {
        let request: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "name=%@ AND colorway=%@", snkr.name, snkr.colorway)
        
        request.predicate = predicate
        
        do {
            let snkrEntities = try context.fetch(request)
            
            context.delete(snkrEntities.first!)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func overlayBlurredBackgroundView() {
        let blurredBackgroundView = UIVisualEffectView()
        blurredBackgroundView.frame = view.frame
        blurredBackgroundView.effect = UIBlurEffect(style: .dark)
        
        view.addSubview(blurredBackgroundView)
    }
    
    private func pickRandomSnkr() -> Snkr {
        var unpickedSnkrs = [Snkr]()
        
        for snkr in snkrs {
            if snkr.lastWornDate == nil {
                unpickedSnkrs.append(snkr)
            }
        }
        
        if unpickedSnkrs.count == 0 {
            for snkr in snkrs {
                snkr.lastWornDate = nil
            }
            
            self.tableView.reloadData()
            
            unpickedSnkrs = snkrs
        }
    
        return unpickedSnkrs[Int(arc4random_uniform(UInt32(unpickedSnkrs.count)))]
    }
    
    internal func cancelPickedSnkr() {
        for subview in view.subviews {
            if subview.isKind(of: UIVisualEffectView.self) {
                subview.removeFromSuperview()
            }
        }
    }
    
    internal func confirmPickedSnkr(snkr: Snkr) {
        for iteratorSnkr in snkrs {
            if iteratorSnkr.name == snkr.name && iteratorSnkr.colorway == snkr.colorway {
                iteratorSnkr.lastWornDate = Date()
            }
        }
        
        self.tableView.reloadData()
    }
}
