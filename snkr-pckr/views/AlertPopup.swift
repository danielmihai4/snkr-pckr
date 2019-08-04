//
//  AlertPopup.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 04/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import SwiftEntryKit
import UIKit

class AlertPopup {
    
    private let title: String
    private let message: String
    private let image: UIImage?
    
    public init(title: String, message: String, image: UIImage?) {
        self.title = title
        self.message = message
        self.image = image
    }
    
    public func getContentView() -> EKAlertMessageView {
        let title = EKProperty.LabelContent(
            text: self.title,
            style: .init(
                font: MainFont.medium.with(size: 15),
                color: EKColor(light: Colors.cadetGrey, dark: Colors.cadetGrey),
                alignment: .center,
                displayMode: EKAttributes.DisplayMode.inferred))
        
        let description = EKProperty.LabelContent(
            text: self.message,
            style: .init(
                font: MainFont.medium.with(size: 13),
                color: EKColor(light: Colors.cadetGrey, dark: Colors.cadetGrey),
                alignment: .center,
                displayMode: EKAttributes.DisplayMode.inferred))
        
        var image: EKProperty.ImageContent?
        if self.image != nil {
            image = EKProperty.ImageContent(
                image: self.image!,
                displayMode: EKAttributes.DisplayMode.inferred,
                size: CGSize(width: 25, height: 25),
                contentMode: .scaleAspectFit)
        }
        
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        
        let okButton = EKProperty.ButtonContent(
            label: EKProperty.LabelContent(text: PopUpLabels.confirmButtonTitle, style: ConfirmPopupStyle.okButtonLabelStyle),
            backgroundColor: .clear,
            highlightedBackgroundColor: EKColor(light: Colors.cadetGrey.withAlphaComponent(0.05), dark: Colors.cadetGrey.withAlphaComponent(0.05)),
            displayMode: EKAttributes.DisplayMode.inferred) {
                SwiftEntryKit.dismiss()
        }
        
        let buttonsBarContent = EKProperty.ButtonBarContent(
            with: okButton,
            separatorColor: EKColor(light: Colors.cadetGrey, dark: Colors.cadetGrey),
            displayMode: EKAttributes.DisplayMode.inferred,
            expandAnimatedly: true)
        
        let contentView = EKAlertMessageView(with: EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent))
        contentView.backgroundColor = Colors.independence
        
        return contentView
    }
    
    public func getAttributes() -> EKAttributes {
        var attributes = EKAttributes()
        attributes = .centerFloat
        attributes.displayMode = EKAttributes.DisplayMode.inferred
        attributes.windowLevel = .alerts
        attributes.displayDuration = .infinity
        attributes.hapticFeedbackType = .success
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = .color(color: EKColor(light: screenBackgroundColor(), dark: screenBackgroundColor()))
        attributes.entryBackground = .color(color: .standardBackground)
        attributes.exitAnimation = .init(fade: .init(from: 1, to: 0, duration: 0.2))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 5))
        attributes.entranceAnimation = .init(
            scale: .init(from: 0.9, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)),
            fade: .init(from: 0, to: 1, duration: 0.3))
        
        return attributes
    }
    
    private func screenBackgroundColor() -> UIColor {
        return Colors.independence.withAlphaComponent(0.8)
    }
    
}
