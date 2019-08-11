//
//  CategoryOptionsPopupView.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 11/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

protocol CategoryOptionsPopupViewDelegate {
    func deleteCategory(_ category: Category)
    func editCategory(_ category: Category)
}

class CategoryOptionsPopupView: UIView {
    
    private let scrollViewVerticalOffset: CGFloat = 20
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private var buttonViews: [EKButtonBarView] = []
    private let category: Category
    private let delegate: CategoryOptionsPopupViewDelegate
    
    public init(with delegate: CategoryOptionsPopupViewDelegate, category: Category) {
        self.category = category
        self.delegate = delegate
        super.init(frame: UIScreen.main.bounds)
        
        setupScrollView()
        setupTitleLabel()
        setupButtons()
        setupTapGestureRecognizer()
        
        scrollView.layoutIfNeeded()
        scrollView.contentSize.height = 200
        self.backgroundColor = Colors.independence
        
        set(.height, of: scrollView.contentSize.height + scrollViewVerticalOffset * 2, priority: .defaultHigh)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getAttributes() -> EKAttributes {
        var attributes = EKAttributes.bottomFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: EKColor(light: Colors.independence, dark: Colors.independence))
        attributes.screenBackground = .color(color: EKColor(light: screenBackgroundColor(), dark: screenBackgroundColor()))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.roundCorners = .all(radius: 25)
        attributes.exitAnimation = .init(translate: .init(duration: 0.2))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        attributes.positionConstraints.verticalOffset = 10
        attributes.positionConstraints.size = .init(width: .offset(value: 20), height: .intrinsic)
        attributes.statusBar = .dark
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.entranceAnimation = .init(translate: .init(duration: 0.5, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.positionConstraints = .fullWidth
        attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
        attributes.roundCorners = .top(radius: 20)
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0.7, spring: .init(damping: 1, initialVelocity: 0)),
            scale: .init(from: 1.05, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)))
        
        return attributes
    }
    
    private func screenBackgroundColor() -> UIColor {
        return Colors.independence.withAlphaComponent(0.8)
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.layoutToSuperview(axis: .horizontally, offset: 20)
        scrollView.layoutToSuperview(axis: .vertically, offset: scrollViewVerticalOffset)
        scrollView.layoutToSuperview(.width, .height, offset: -scrollViewVerticalOffset * 2)
    }
    
    private func setupTitleLabel() {
        scrollView.addSubview(titleLabel)
        titleLabel.layoutToSuperview(.top, .width)
        titleLabel.layoutToSuperview(axis: .horizontally)
        titleLabel.forceContentWrap(.vertically)
        titleLabel.text = PopUpLabels.optionsTitle
        titleLabel.font = MainFont.demiBold.with(size: 20)
        titleLabel.textColor = Colors.cadetGrey
    }
    
    private func setupButtons() {
        var buttonViews = [EKButtonBarView]()
        
        let editCategoryButtonBarView = creatEditCategoryButtonBarView()
        scrollView.addSubview(editCategoryButtonBarView)
        buttonViews.append(editCategoryButtonBarView)
        
        let deleteCategoryButtonBarView = createDeleteCategoryButtonBarView()
        scrollView.addSubview(deleteCategoryButtonBarView)
        buttonViews.append(deleteCategoryButtonBarView)
        
        buttonViews.first!.layout(.top, to: .bottom, of: titleLabel, offset: 20)
        buttonViews.spread(.vertically, offset: 5)
        buttonViews.layoutToSuperview(axis: .horizontally)
    }
    
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapGestureRecognized)
        )
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapGestureRecognized() {
        endEditing(true)
    }
    
    private func creatEditCategoryButtonBarView() -> EKButtonBarView {
        let editCategoryButtonContent = EKProperty.ButtonContent(
            label: .init(text: PopUpLabels.editCategoryButtonTitle, style: OptionsPopupStyle.buttonStyle),
            backgroundColor: EKColor(light: Colors.cadetGrey.withAlphaComponent(0.5), dark: Colors.cadetGrey.withAlphaComponent(0.5)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {
                self.delegate.editCategory(self.category)
                SwiftEntryKit.dismiss()
        }
        let editCategoryButtonBarContent = EKProperty.ButtonBarContent(with: editCategoryButtonContent, separatorColor: .clear, expandAnimatedly: true)
        let editCategoryButtonBarView = EKButtonBarView(with: editCategoryButtonBarContent)
        editCategoryButtonBarView.clipsToBounds = true
        editCategoryButtonBarView.tag = 0
        editCategoryButtonBarView.expand()
        
        return editCategoryButtonBarView
    }
    
    private func createDeleteCategoryButtonBarView() -> EKButtonBarView {
        let deleteCategoryButtonContent = EKProperty.ButtonContent(
            label: .init(text: PopUpLabels.deleteCategoryButtonTitle, style: OptionsPopupStyle.buttonStyle),
            backgroundColor: EKColor(light: Colors.cadetGrey.withAlphaComponent(0.2), dark: Colors.cadetGrey.withAlphaComponent(0.2)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {  [unowned self] in
                SwiftEntryKit.dismiss()
                
                self.delegate.deleteCategory(self.category)
                
        }
        let deleteCategoryButtonBarContent = EKProperty.ButtonBarContent(with: deleteCategoryButtonContent, separatorColor: .clear, expandAnimatedly: true)
        let deleteCategoryButtonBarView = EKButtonBarView(with: deleteCategoryButtonBarContent)
        deleteCategoryButtonBarView.clipsToBounds = true
        deleteCategoryButtonBarView.tag = 0
        deleteCategoryButtonBarView.expand()
        
        return deleteCategoryButtonBarView
    }
}
