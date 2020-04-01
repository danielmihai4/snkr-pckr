//
//  SnkrsTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 17/11/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import UIKit
import CoreData
import SwiftEntryKit

class SnkrsTableViewController: UITableViewController, TableViewCellDelegate, PickedSnkrModalViewControllerDelegate, PopUpOptionsControlleDelegate, ConfirmationPopupDelegate {
    
    var snkrs = [Snkr]() {
        didSet {
            self.setTitle()
        }
    }
    var filteredSnkrs = [Snkr]()
    var snkrService = SnkrService()
    var snkrToDelete: Snkr?
    
    @IBOutlet weak var searchFooter: SearchFooter!
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSnkrs()
        setupTableView()
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
        return 300
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Snkr, for: indexPath) as! SnkrTableViewCell
        let snkr = isFiltering() ? filteredSnkrs[indexPath.row] : snkrs[indexPath.row]
        
        cell.pic.image = snkr.pic
        cell.nameLabel.text = snkr.name
        cell.lastWornLabel.text = DateUtils.formatDate(lastWornDate: snkr.lastWornDate)
        cell.colorwayLabel.text = snkr.colorway
        cell.delegate = self
        
        if (snkrs.firstIndex{$0 === snkr} == 0) {
            cell.addTopBorder()
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Segues.ShowPickedSnkr {
                if let viewController = segue.destination as? PickedSnkrModalViewController {
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
                id: UUID(),
                name: source.nameTextField.text!,
                colorway: source.colorwayTextField.text!,
                lastWornDate: nil,
                isClean: true,
                pic: resizedPicture)
            
            snkrs.append(snkr)
            
            snkrService.store(snkr: snkr)
        }
    }
    
    @IBAction func showOptions(_ sender: Any) {
        
        if let cell = (sender as AnyObject).superview??.superview?.superview as? SnkrTableViewCell {
            let indexPath = tableView.indexPath(for: cell)
            let snkr = snkrs[(indexPath?.row)!]
            let contentView = SnkrOptionsPopupView(with: self, snkr: snkr)
            
            SwiftEntryKit.display(entry: contentView, using: contentView.getAttributes(), presentInsideKeyWindow: true)
        }
    }
    
    @IBAction func cancel(segue:UIStoryboardSegue) {
        //nothing to do.
    }
    
    @IBAction func pickSnkr(_ sender: Any) {
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        
        self.overlayBlurredBackgroundView()
    }
    
    
    internal func doubleTap(cell: UITableViewCell) {
        if let snkrViewCell = cell as? SnkrTableViewCell {
            let indexPath = tableView.indexPath(for: snkrViewCell)
            let snkr = snkrs[(indexPath?.row)!]
            let contentView = SnkrOptionsPopupView(with: self, snkr: snkr)
            
            SwiftEntryKit.display(entry: contentView, using: contentView.getAttributes(), presentInsideKeyWindow: true)
        }
    }
    
    private func setupTableView() {
        self.tableView.tableFooterView = searchFooter
        self.tableView.separatorStyle = .none
        self.tableView.showsVerticalScrollIndicator = false
    }
    
    private func filterContentForSearchText(searchText: String) {
        filteredSnkrs = snkrs.filter({(snkr : Snkr) -> Bool in
            let snkrTitle = getSnkrTitle(snkr: snkr)
            let doesMatch = snkrTitle.lowercased().contains(searchText.lowercased())
            
            return searchBarIsEmpty() ? false : doesMatch
        })
        
        self.tableView.reloadData()
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
    
    private func getSnkrTitles() -> [String] {
        var snkrTitles = [String]()
        
        for snkr in snkrs {
            snkrTitles.append(getSnkrTitle(snkr: snkr))
        }
        
        return snkrTitles
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
        snkrs = snkrService.loadAll()
    }
    
    private func setTitle() {
        
        if (snkrs.count == 1) {
            self.title = String(format: "%d Snkr", snkrs.count)
        } else {
            self.title = String(format: "%d Snkrs", snkrs.count)
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
                self.snkrService.update(snkr: snkr)
            }
        }
        
        self.tableView.reloadData()
    }
    
    internal func deleteSnkr(_ snkr: Snkr) {
        snkrToDelete = snkr
        
        let confirmationPopup = ConfirmationPopup(title: PopUpLabels.confirmDeleteSnkrPopupTitle, image: snkr.pic, delegate: self)
        
        SwiftEntryKit.display(entry: confirmationPopup.getContentView(), using: confirmationPopup.getAttributes())
    }
    
    internal func toggleWearState(_ snkr: Snkr) {
        snkr.lastWornDate = snkr.lastWornDate != nil ? nil : Date()
        
        self.snkrService.update(snkr: snkr)
        self.tableView.reloadData()
    }
    
    internal func markToClean(_ snkr: Snkr) {
        snkr.isClean = false
        
        snkrService.update(snkr: snkr)
    }
    
    internal func performCancelAction() {
        snkrToDelete = nil
    }
    
    internal func performConfirmAction() {
        let index = self.snkrs.firstIndex{$0 === snkrToDelete}
        let indexPath = IndexPath(row: index!, section: 0)
        
        self.snkrs.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        self.snkrService.delete(snkr: self.snkrToDelete!)
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


