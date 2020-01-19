//
//  SnkrOptionsPopup.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 03/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit
import SwiftEntryKit

protocol PopUpOptionsControlleDelegate {
    func deleteSnkr(_ snkr: Snkr)
    func toggleWearState(_ snkr: Snkr)
    func markToClean(_ snkr: Snkr)
}

class SnkrOptionsPopupView: UIView {
    
    private let scrollViewVerticalOffset: CGFloat = 20
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private var buttonViews: [EKButtonBarView] = []
    private let snkr: Snkr
    private let delegate: PopUpOptionsControlleDelegate
    
    public init(with delegate: PopUpOptionsControlleDelegate, snkr: Snkr) {
        self.snkr = snkr
        self.delegate = delegate
        super.init(frame: UIScreen.main.bounds)
        
        setupScrollView()
        setupTitleLabel()
        setupButtons()
        setupTapGestureRecognizer()
        
        scrollView.layoutIfNeeded()
        scrollView.contentSize.height = 220
        self.backgroundColor = Colors.umber
        
        set(.height, of: scrollView.contentSize.height + scrollViewVerticalOffset * 2, priority: .defaultHigh)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getAttributes() -> EKAttributes {
        var attributes = EKAttributes.bottomFloat
        attributes.hapticFeedbackType = .success
        attributes.displayDuration = .infinity
        attributes.entryBackground = .color(color: EKColor(light: Colors.umber, dark: Colors.umber))
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
        return Colors.umber.withAlphaComponent(0.8)
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
        titleLabel.textColor = Colors.darkVanilla
    }
    
    private func setupButtons() {
        var buttonViews = [EKButtonBarView]()
       
        let wearSnkrButtonBarView = createWearSnkrButtonBarView()
        scrollView.addSubview(wearSnkrButtonBarView)
        buttonViews.append(wearSnkrButtonBarView)
        
        let cleanSnkrButtonBarView = createCleanSnkrButtonBarView()
        scrollView.addSubview(cleanSnkrButtonBarView)
        buttonViews.append(cleanSnkrButtonBarView)
        
        let deleteSnkrButtonBarView = createDeleteSnkrButtonBarView()
        scrollView.addSubview(deleteSnkrButtonBarView)
        buttonViews.append(deleteSnkrButtonBarView)
        
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
    
    private func createWearSnkrButtonBarView() -> EKButtonBarView {
        let title = snkr.lastWornDate == nil ? PopUpLabels.wearSnkrButtonTitle : PopUpLabels.unselectSnkrButtonTitle
        let wearSnkrButtonContent = EKProperty.ButtonContent(
            label: .init(text: title, style: OptionsPopupStyle.buttonStyle),
            backgroundColor: EKColor(light: Colors.darkVanilla.withAlphaComponent(0.5), dark: Colors.darkVanilla.withAlphaComponent(0.5)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {
                self.delegate.toggleWearState(self.snkr)
                SwiftEntryKit.dismiss()
        }
        let wearSnkrButtonBarContent = EKProperty.ButtonBarContent(with: wearSnkrButtonContent, separatorColor: .clear, expandAnimatedly: true)
        let wearSnkrButtonBarView = EKButtonBarView(with: wearSnkrButtonBarContent)
        wearSnkrButtonBarView.clipsToBounds = true
        wearSnkrButtonBarView.tag = 0
        wearSnkrButtonBarView.expand()
        
        return wearSnkrButtonBarView
    }
    
    private func createCleanSnkrButtonBarView() -> EKButtonBarView {
        let cleanSnkrButtonContent = EKProperty.ButtonContent(
            label: .init(text: PopUpLabels.cleanSnkrButtonTitle, style: OptionsPopupStyle.buttonStyle),
            backgroundColor: EKColor(light: Colors.darkVanilla.withAlphaComponent(0.5), dark: Colors.darkVanilla.withAlphaComponent(0.5)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {
                self.delegate.markToClean(self.snkr)
                SwiftEntryKit.dismiss()
        }
        let cleanSnkrButtonBarContent = EKProperty.ButtonBarContent(with: cleanSnkrButtonContent, separatorColor: .clear, expandAnimatedly: true)
        let cleanSnkrButtonBarView = EKButtonBarView(with: cleanSnkrButtonBarContent)
        cleanSnkrButtonBarView.clipsToBounds = true
        cleanSnkrButtonBarView.tag = 0
        cleanSnkrButtonBarView.expand()
        
        return cleanSnkrButtonBarView
    }
    
    private func createDeleteSnkrButtonBarView() -> EKButtonBarView {
        let deleteSnkrButtonContent = EKProperty.ButtonContent(
            label: .init(text: PopUpLabels.deleteSnkrButtonTitle, style: OptionsPopupStyle.buttonStyle),
            backgroundColor: EKColor(light: Colors.darkVanilla.withAlphaComponent(0.2), dark: Colors.darkVanilla.withAlphaComponent(0.2)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {  [unowned self] in
                SwiftEntryKit.dismiss()
                
                self.delegate.deleteSnkr(self.snkr)
                
        }
        let deleteSnkrButtonBarContent = EKProperty.ButtonBarContent(with: deleteSnkrButtonContent, separatorColor: .clear, expandAnimatedly: true)
        let deleteSnkrButtonBarView = EKButtonBarView(with: deleteSnkrButtonBarContent)
        deleteSnkrButtonBarView.clipsToBounds = true
        deleteSnkrButtonBarView.tag = 0
        deleteSnkrButtonBarView.expand()
        
        return deleteSnkrButtonBarView
    }
    

}
