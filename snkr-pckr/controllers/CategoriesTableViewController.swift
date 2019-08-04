//
//  CategoriesTableViewController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

class CategoriesTableViewController: UITableViewController {
    
    var categories = [Category]()
    var categoryService = CategoryService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categories = categoryService.loadAll()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCell.EditingStyle.delete) {
            let category = self.categories[indexPath.row]
            
            self.categoryService.delete(category: category)
            self.categories.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segues.ShowSnkrSelector {
            let destination = segue.destination as! SnkrSelectorTableViewController
            let buttonPosition = (sender as! UIButton).convert(CGPoint(), to:tableView)
            let indexPath = tableView.indexPathForRow(at:buttonPosition)
            
            destination.category = categories[(indexPath?.row)!]
        } else if segue.identifier == Segues.ShowCategorySnkrs {
            let destination = segue.destination as! CategorySnkrsModalViewController
            let indexPath = tableView.indexPathForSelectedRow
            
            destination.category = categories[(indexPath?.row)!]
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.Category, for: indexPath) as! CategoryViewCell
        let category = categories[indexPath.row]
        
        cell.nameLabel.text = category.name
        cell.snkrCountLabel.text = displaySnkrCount(snkrCount: category.snkrs.count)
        
        return cell
    }
    
    @IBAction func addCategory(_ sender: Any) {
        SwiftEntryKit.display(entry: createContentView(), using: createAttributes(), presentInsideKeyWindow: true)
    }
    
    private func displaySnkrCount(snkrCount: Int) -> String {
        if snkrCount == 0 {
            return CellLabels.noSnkrsSelected
        }
        
        return "\(snkrCount) snkrs."
    }
    
    private func saveCategory(name: String) {
        let category = Category(id: UUID(), name: name)
        
        categoryService.store(category: category)
        categories.append(category)
        tableView.reloadData()
    }
    
    private func createContentView() -> EKFormMessageView {
        let title = createTitle()
        let nameTextField = createNameTextField()
        let button = createButton(nameTextField)
        
        let contentView = EKFormMessageView(with: title, textFieldsContent: [nameTextField], buttonContent: button)
        contentView.backgroundColor = Colors.independence
        
        return contentView
    }
    
    private func createTitle() -> EKProperty.LabelContent {
        return EKProperty.LabelContent(text: PopUpLabels.newCategoryTitle, style: NewCategoryPopupStyle.titleStyle)
    }
    
    private func createNameTextField() -> EKProperty.TextFieldContent {
        return EKProperty.TextFieldContent(keyboardType: .namePhonePad,
                                           placeholder: createPlaceholder(),
                                           tintColor: EKColor(light: Colors.cadetGrey, dark: Colors.cadetGrey),
                                           displayMode: EKAttributes.DisplayMode.inferred,
                                           textStyle: NewCategoryPopupStyle.textStyle,
                                           leadingImage: UIImage(named: "icon-category")!.withRenderingMode(.alwaysTemplate),
                                           bottomBorderColor: EKColor(light: Colors.cadetGrey, dark: Colors.cadetGrey),
                                           accessibilityIdentifier: "nameTextFiled")
    }
    
    private func createPlaceholder() -> EKProperty.LabelContent {
        return EKProperty.LabelContent (text: PopUpLabels.newCategoryNamePlaceholder, style: NewCategoryPopupStyle.placeholderStyle)
    }
    
    private func createButton(_ nameTextField: EKProperty.TextFieldContent) -> EKProperty.ButtonContent {
        return EKProperty.ButtonContent(
            label: .init(text: PopUpLabels.newCategorySaveButtonTitle, style: NewCategoryPopupStyle.buttonStyle),
            backgroundColor: EKColor(light: Colors.cadetGrey.withAlphaComponent(0.5), dark: Colors.cadetGrey.withAlphaComponent(0.5)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {
                let categoryName = nameTextField.textContent
                if (!categoryName.isEmpty) {
                    self.saveCategory(name: categoryName)
                    SwiftEntryKit.dismiss()
                }
        }
    }
    
    private func createAttributes() -> EKAttributes {
        var attributes = EKAttributes()
        attributes.positionConstraints = .fullWidth
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
        attributes.windowLevel = .statusBar
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.popBehavior = .animated(animation: .translation)
        attributes.displayDuration = .infinity
        attributes.windowLevel = .normal
        attributes.position = .bottom
        attributes.displayDuration = .infinity
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.65,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(
                duration: 0.65,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(
                    duration: 0.65,
                    spring: .init(damping: 1, initialVelocity: 0)
                )
            )
        )
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        attributes.entryBackground = .gradient(
            gradient: .init(
                colors: [EKColor(rgb: 0x485563), EKColor(rgb: 0x29323c)],
                startPoint: .zero,
                endPoint: CGPoint(x: 1, y: 1)
            )
        )
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.3,
                radius: 3
            )
        )
        
        attributes.screenBackground = .color(color: EKColor(light: screenBackgroundColor(), dark: screenBackgroundColor()))
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.statusBar = .light
        attributes.positionConstraints.keyboardRelation = .bind(
            offset: .init(
                bottom: 0,
                screenEdgeResistance: 0
            )
        )
        return attributes
    }
    
    private func screenBackgroundColor() -> UIColor {
        return Colors.independence.withAlphaComponent(0.8)
    }
}
