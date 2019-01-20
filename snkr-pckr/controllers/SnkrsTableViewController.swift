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
    
    var snkrs = [Snkr]() {
        didSet {
            self.setTitle()
        }
    }
    var filteredSnkrs = [Snkr]()
    
    @IBOutlet weak var searchFooter: SearchFooter!
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSnkrs()
        
        tableView.tableFooterView = searchFooter
        tableView.separatorStyle = .none
        
        setupSearchController()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredSnkrs.count, of: filteredSnkrs.count)
            return filteredSnkrs.count
        }
        
        searchFooter.setNotFiltering()
        return snkrs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 355
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Snkr, for: indexPath) as! SnkrTableViewCell
        let snkr = isFiltering() ? filteredSnkrs[indexPath.row] : snkrs[indexPath.row]
        
        cell.pic.image = snkr.pic
        cell.nameLabel.text = snkr.name
        cell.lastWornLabel.text = DateUtils.formatDate(lastWornDate: snkr.lastWornDate)//formatDate(lastWornDate: snkr.lastWornDate)
        cell.colorwayLabel.text = snkr.colorway
        
        return cell
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
                isClean: true,
                pic: resizedPicture)
            
            snkrs.append(snkr)
            
            storeSnkrEntity(snkr: snkr)
        }
    }
    @IBAction func showOptions(_ sender: Any) {
        
        if let cell = (sender as AnyObject).superview??.superview?.superview as? SnkrTableViewCell {
            let indexPath = tableView.indexPath(for: cell)
            let snkr = snkrs[(indexPath?.row)!]
            let optionMenu = UIAlertController(title: nil, message: AlertLabels.optionsTitle, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: ButtonLabels.cancel, style: .cancel)
            let deleteAction = UIAlertAction(title: ButtonLabels.delete, style: .destructive, handler: { (action) -> Void in
                self.deleteSnkr(indexPath: indexPath!)
            });
            let cleanAction = UIAlertAction(title: ButtonLabels.clean, style: .default, handler: { (action) -> Void in
                self.markSnkrToClean(indexPath: indexPath!)
            });
            
            if snkr.lastWornDate == nil {
                let selectSnkrAction = UIAlertAction(title: ButtonLabels.wearSnkr, style: .default, handler: { (action) -> Void in
                    self.toggleWearState(indexPath: indexPath!)
                });
                
                optionMenu.addAction(selectSnkrAction)
            } else {
                let unselectSnkrAction = UIAlertAction(title: ButtonLabels.unselectSnkr, style: .default, handler: { (action) -> Void in
                    self.toggleWearState(indexPath: indexPath!)
                });
                
                optionMenu.addAction(unselectSnkrAction)
            }
            
            optionMenu.addAction(cleanAction)
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    @IBAction func pickSnkr(_ sender: Any) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        
        self.overlayBlurredBackgroundView()
    }
    
    private func filterContentForSearchText(searchText: String) {
        filteredSnkrs = snkrs.filter({(snkr : Snkr) -> Bool in
            let snkrTitle = getSnkrTitle(snkr: snkr)
            let doesMatch = snkrTitle.lowercased().contains(searchText.lowercased())
            
            return searchBarIsEmpty() ? false : doesMatch
        })
        
        tableView.reloadData()
    }
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Search Snkrs"
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func markSnkrToClean(indexPath: IndexPath) {
        let snkr = self.snkrs[indexPath.row]
        snkr.isClean = false
        
        self.updateSnkrEntity(snkr: snkr)
    }
    
    private func getSnkrTitles() -> [String] {
        var snkrTitles = [String]()
        
        for snkr in snkrs {
            snkrTitles.append(getSnkrTitle(snkr: snkr))
        }
        
        return snkrTitles
    }
    
    private func toggleWearState(indexPath: IndexPath) {
        let snkr = self.snkrs[indexPath.row]
        
        if snkr.lastWornDate != nil {
            snkr.lastWornDate = nil
        } else {
            snkr.lastWornDate = Date()
        }
        
        self.updateSnkrEntity(snkr: snkr)
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
                    isClean: snkrEntity.isClean,
                    pic: UIImage(data: snkrEntity.pic!)!)
                                
                snkrs.append(snkr)
            }
        } catch {
            print ("Cannot load snkrs")
        }
    }
    
    private func setTitle() {
        
        if (snkrs.count == 1) {
            self.title = String(format: "%d Snkr", snkrs.count)
        } else {
            self.title = String(format: "%d Snkrs", snkrs.count)
        }
    }
    
    private func storeSnkrEntity(snkr: Snkr) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let snkrEntity = SnkrEntity(context: context)
        
        snkrEntity.name = snkr.name
        snkrEntity.colorway = snkr.colorway
        snkrEntity.lastWornDate = snkr.lastWornDate
        snkrEntity.isClean = snkr.isClean!
        snkrEntity.pic = UIImageJPEGRepresentation(snkr.pic, 1)
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
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
    
    private func deleteSnkrEntity(snkr: Snkr) {
        let request: NSFetchRequest<SnkrEntity> = SnkrEntity.fetchRequest()
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let predicate = NSPredicate(format: "name=%@ AND colorway=%@", snkr.name, snkr.colorway)
        
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
    
    private func getSnkrTitle(snkr: Snkr) -> String {
        return "\(snkr.name)\(snkr.colorway)"
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
                updateSnkrEntity(snkr: snkr)
            }
        }
        
        self.tableView.reloadData()
    }
}

extension SnkrsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!)
    }
}

extension SnkrsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}


