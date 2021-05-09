//
//  CategoryOptionsView.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/05/2021.
//  Copyright © 2021 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

protocol CategoryOptionsPopupViewDelegate {
    func selectSnkrs(_ category: Category)
    func deleteCategory(_ category: Category)
}

class CategoryOptionsPopupView: UIView {

    private let defaultHeight: CGFloat = 250
    private let scrollViewHorizontalOffset: CGFloat = 20
    private let scrollViewVerticalOffset: CGFloat = 20
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private var buttonViews: [EKButtonBarView] = []
    private let delegate: CategoryOptionsPopupViewDelegate
    private let category: Category
    
    public init(delegate: CategoryOptionsPopupViewDelegate, category: Category) {
        self.delegate = delegate
        self.category = category
        super.init(frame: UIScreen.main.bounds)
        
        setupScrollView()
        setupTitleLabel()
        setupButtons()
        setupTapGestureRecognizer()
        
        scrollView.layoutIfNeeded()
        scrollView.contentSize.height = defaultHeight
        self.backgroundColor = UIColor.darkGray
        
        set(.height, of: scrollView.contentSize.height + scrollViewVerticalOffset * 2, priority: .defaultHigh)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getAttributes() -> EKAttributes {
        var attributes = EKAttributes.bottomFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: EKColor(light: UIColor.darkGray, dark: UIColor.darkGray))
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
        return UIColor.darkGray.withAlphaComponent(0.8)
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.layoutToSuperview(axis: .horizontally, offset: scrollViewHorizontalOffset)
        scrollView.layoutToSuperview(axis: .vertically, offset: scrollViewVerticalOffset)
        scrollView.layoutToSuperview(.width, .height, offset: -scrollViewVerticalOffset * 2)
    }
    
    private func setupTitleLabel() {
        scrollView.addSubview(titleLabel)
        titleLabel.layoutToSuperview(.top, .width)
        titleLabel.layoutToSuperview(axis: .horizontally)
        titleLabel.forceContentWrap(.vertically)
        titleLabel.text = PopUpLabels.selectImageTitle
        titleLabel.font = MainFont.demiBold.with(size: 20)
        titleLabel.textColor = UIColor.white
    }
    
    private func setupButtons() {
        var buttonViews = [EKButtonBarView]()
        
        let selectSnkrsButtonBarView = createSelectSnkrsButtonBarView()
        scrollView.addSubview(selectSnkrsButtonBarView)
        buttonViews.append(selectSnkrsButtonBarView)
        
        let deleteButtonBarView = createDeleteButtonBarView()
        scrollView.addSubview(deleteButtonBarView)
        buttonViews.append(deleteButtonBarView)
        
        let cancelButtonBarView = createCancelButtonBarView()
        scrollView.addSubview(cancelButtonBarView)
        buttonViews.append(cancelButtonBarView)
        
        buttonViews.first!.layout(.top, to: .bottom, of: titleLabel, offset: 20)
        buttonViews.spread(.vertically, offset: 5)
        buttonViews.layoutToSuperview(axis: .horizontally)
    }
    
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func tapGestureRecognized() {
        endEditing(true)
    }
    
    private func createSelectSnkrsButtonBarView() -> EKButtonBarView {
        let imagePickerButtonContent = EKProperty.ButtonContent(
            label: .init(text: PopUpLabels.selectSnkrsTitle, style: OptionsPopupStyle.buttonStyle),
            backgroundColor: EKColor(light: UIColor.lightGray.withAlphaComponent(0.8), dark: UIColor.lightGray.withAlphaComponent(0.8)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {
                self.delegate.selectSnkrs(self.category)
                SwiftEntryKit.dismiss()
        }
        
        let imagePickerButtonBarContent = EKProperty.ButtonBarContent(with: imagePickerButtonContent, separatorColor: .clear, expandAnimatedly: true)
        let imagePickerButtonBarView = EKButtonBarView(with: imagePickerButtonBarContent)
        imagePickerButtonBarView.clipsToBounds = true
        imagePickerButtonBarView.tag = 0
        imagePickerButtonBarView.expand()
        
        return imagePickerButtonBarView
    }
    
    private func createCancelButtonBarView() -> EKButtonBarView {
        let cancelButtonContent = EKProperty.ButtonContent(
            label: .init(text: PopUpLabels.cancelButtonTitle, style: OptionsPopupStyle.buttonStyle),
            backgroundColor: EKColor(light: UIColor.lightGray.withAlphaComponent(0.5), dark: UIColor.lightGray.withAlphaComponent(0.5)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {
                SwiftEntryKit.dismiss()
        }
        
        let cancelButtonBarContent = EKProperty.ButtonBarContent(with: cancelButtonContent, separatorColor: .clear, expandAnimatedly: true)
        let cancelButtonBarView = EKButtonBarView(with: cancelButtonBarContent)
        cancelButtonBarView.clipsToBounds = true
        cancelButtonBarView.tag = 0
        cancelButtonBarView.expand()
        
        return cancelButtonBarView
    }
    
    private func createDeleteButtonBarView() -> EKButtonBarView {
        let urlDownloadButtonContent = EKProperty.ButtonContent(
            label: .init(text: PopUpLabels.deleteCategoryTitle, style: OptionsPopupStyle.buttonStyle),
            backgroundColor: EKColor(light: UIColor.lightGray.withAlphaComponent(0.8), dark: UIColor.lightGray.withAlphaComponent(0.8)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {
                SwiftEntryKit.dismiss()
                self.delegate.deleteCategory(self.category)
        }
        
        let urlDownloadButtonBarContent = EKProperty.ButtonBarContent(with: urlDownloadButtonContent, separatorColor: .clear, expandAnimatedly: true)
        let urlDownloadButtonBarView = EKButtonBarView(with: urlDownloadButtonBarContent)
        urlDownloadButtonBarView.clipsToBounds = true
        urlDownloadButtonBarView.tag = 0
        urlDownloadButtonBarView.expand()
        
        return urlDownloadButtonBarView
    }
}
