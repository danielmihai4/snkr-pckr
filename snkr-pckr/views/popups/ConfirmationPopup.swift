//
//  ConfirmPopup.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 04/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import SwiftEntryKit
import UIKit

protocol ConfirmationPopupDelegate {
    func performConfirmAction()
    func performCancelAction()
}

class ConfirmationPopup {
    
    private let title: String
    private let titleAlignment: NSTextAlignment
    private let image: UIImage?
    private let delegate: ConfirmationPopupDelegate
    
    public init(title: String, titleAlignment: NSTextAlignment = .left, image: UIImage?, delegate: ConfirmationPopupDelegate) {
        self.title = title
        self.titleAlignment = titleAlignment
        self.image = image
        self.delegate = delegate
    }
    
    public func getContentView() -> EKAlertMessageView {
        let title = EKProperty.LabelContent(
            text: self.title,
            style: .init(
                font: MainFont.medium.with(size: 15),
                color: EKColor(light: UIColor.white, dark: UIColor.white),
                alignment: self.titleAlignment,
                displayMode: EKAttributes.DisplayMode.inferred
            )
        )
        let description = EKProperty.LabelContent(
            text: "",
            style: .init(
                font: MainFont.regular.with(size: 13),
                color: .black,
                displayMode: EKAttributes.DisplayMode.inferred
            )
        )
        
        var image: EKProperty.ImageContent?
        if self.image != nil {
            image = EKProperty.ImageContent(
                image: self.image!,
                displayMode: EKAttributes.DisplayMode.inferred,
                size: CGSize(width: 35, height: 35),
                contentMode: .scaleAspectFit
            )
        }
        
        let simpleMessage = EKSimpleMessage(
            image: image,
            title: title,
            description: description
        )
        
        let closeButtonLabel = EKProperty.LabelContent(
            text: PopUpLabels.cancelButtonTitle,
            style: ConfirmPopupStyle.closeButtonLabelStyle
        )
        let closeButton = EKProperty.ButtonContent(
            label: closeButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(light: UIColor.white.withAlphaComponent(0.05), dark: UIColor.white.withAlphaComponent(0.05))) {
                SwiftEntryKit.dismiss()
                self.delegate.performCancelAction()
        }
        
        let okButtonLabel = EKProperty.LabelContent(
            text: PopUpLabels.confirmButtonTitle,
            style: ConfirmPopupStyle.okButtonLabelStyle
        )
        let okButton = EKProperty.ButtonContent(
            label: okButtonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(light: UIColor.white.withAlphaComponent(0.05), dark: UIColor.white.withAlphaComponent(0.05)),
            displayMode: EKAttributes.DisplayMode.inferred) {
                SwiftEntryKit.dismiss()
                self.delegate.performConfirmAction()
        }
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: closeButton, okButton,
            separatorColor: EKColor(light: UIColor.white, dark: UIColor.white),
            buttonHeight: 60,
            displayMode: EKAttributes.DisplayMode.inferred,
            expandAnimatedly: true
        )
        let alertMessage = EKAlertMessage(
            simpleMessage: simpleMessage,
            imagePosition: .left,
            buttonBarContent: buttonsBarContent
        )
        
        return EKAlertMessageView(with: alertMessage)
    }
    
    public func getAttributes() -> EKAttributes {
        var attributes = EKAttributes()
        attributes = .topFloat
        attributes.displayMode = EKAttributes.DisplayMode.inferred
        attributes.hapticFeedbackType = .success
        attributes.statusBar = .dark
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.screenBackground = .color(color: EKColor(light: screenBackgroundColor(), dark: screenBackgroundColor()))
        attributes.entryBackground = .color(color: EKColor(light: UIColor.darkGray, dark: UIColor.darkGray))
        attributes.border = .value(color: UIColor.white.withAlphaComponent(0.5), width: 0.5)
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 5))
        attributes.entranceAnimation = .init(
            translate: .init(duration: 0.7, spring: .init(damping: 1, initialVelocity: 0)),
            scale: .init(from: 0.6, to: 1, duration: 0.7),
            fade: .init(from: 0.8, to: 1, duration: 0.3))
        attributes.exitAnimation = .init(
            scale: .init(from: 1, to: 0.7, duration: 0.3),
            fade: .init(from: 1, to: 0, duration: 0.3))
        
        return attributes
    }
    
    private func screenBackgroundColor() -> UIColor {
        return UIColor.darkGray.withAlphaComponent(0.8)
    }
}
