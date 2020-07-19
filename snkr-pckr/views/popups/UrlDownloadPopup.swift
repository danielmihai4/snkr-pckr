//
//  UrlDownloadPopup.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 15/12/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import SwiftEntryKit
import UIKit

protocol UrlDownloadPopupDelegate {
    func download(urlString: String)
}

class UrlDownloadPopup {
    
    private let delegate: UrlDownloadPopupDelegate
    
    public init(_ delegate: UrlDownloadPopupDelegate) {
        self.delegate = delegate
    }
    
    public func getContentView() -> EKFormMessageView {
        let title = createTitle()
        let nameTextField = createNameTextField()
        let button = createButton(nameTextField)
        
        let contentView = EKFormMessageView(with: title, textFieldsContent: [nameTextField], buttonContent: button)
        contentView.backgroundColor = UIColor.darkGray
        
        return contentView
    }
    
    
    public func getAttributes() -> EKAttributes {
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
        attributes.entranceAnimation = .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.exitAnimation = .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.65, spring: .init(damping: 1, initialVelocity: 0))))
        attributes.entryInteraction = .absorbTouches
        attributes.screenInteraction = .dismiss
        attributes.entryBackground = .color(color: EKColor(light: UIColor.darkGray, dark: UIColor.darkGray))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 3))
        attributes.screenBackground = .color(color: EKColor(light: UIColor.darkGray.withAlphaComponent(0.8), dark: UIColor.darkGray.withAlphaComponent(0.8)))
        attributes.scroll = .edgeCrossingDisabled(swipeable: true)
        attributes.statusBar = .light
        attributes.positionConstraints.keyboardRelation = .bind(offset: .init(bottom: 0, screenEdgeResistance: 0))
        
        return attributes
    }
    
    private func createTitle() -> EKProperty.LabelContent {
        return EKProperty.LabelContent(text: PopUpLabels.urlDownloadTitle, style: PopupStyle.titleStyle)
    }
    
    private func createNameTextField() -> EKProperty.TextFieldContent {
        return EKProperty.TextFieldContent(keyboardType: .namePhonePad,
                                           placeholder: createPlaceholder(),
                                           tintColor: EKColor(light: UIColor.white, dark: UIColor.white),
                                           displayMode: EKAttributes.DisplayMode.inferred,
                                           textStyle: PopupStyle.textStyle,
                                           leadingImage: UIImage(named: "icon-url")!.withRenderingMode(.alwaysTemplate),
                                           bottomBorderColor: EKColor(light: UIColor.white, dark: UIColor.white),
                                           accessibilityIdentifier: "nameTextFiled")
    }
    
    private func createPlaceholder() -> EKProperty.LabelContent {
        return EKProperty.LabelContent (text: PopUpLabels.downloadUrlPlaceholder, style: PopupStyle.placeholderStyle)
    }
    
    private func createButton(_ nameTextField: EKProperty.TextFieldContent) -> EKProperty.ButtonContent {
        return EKProperty.ButtonContent(
            label: .init(text: PopUpLabels.downloadUrlButtonTitle, style: PopupStyle.buttonStyle),
            backgroundColor: EKColor(light: UIColor.lightGray.withAlphaComponent(0.8), dark: UIColor.lightGray.withAlphaComponent(0.8)),
            highlightedBackgroundColor: EKColor.white.with(alpha: 0.8),
            displayMode: EKAttributes.DisplayMode.inferred) {
                let urlString = nameTextField.textContent
                if (!urlString.isEmpty) {
                    SwiftEntryKit.dismiss()
                    self.delegate.download(urlString: urlString)
                }
        }
    }
}
