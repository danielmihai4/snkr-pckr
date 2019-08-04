//
//  ConfirmPopupStyle.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 04/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import SwiftEntryKit

class ConfirmPopupStyle {
    
    static let closeButtonLabelStyle = EKProperty.LabelStyle(
        font: MainFont.medium.with(size: 16),
        color: EKColor(light: Colors.cadetGrey.withAlphaComponent(0.3), dark: Colors.cadetGrey.withAlphaComponent(0.3)),
        displayMode: EKAttributes.DisplayMode.inferred)
    
    static let okButtonLabelStyle = EKProperty.LabelStyle(
        font: MainFont.medium.with(size: 16),
        color: EKColor(light: Colors.cadetGrey, dark: Colors.cadetGrey),
        displayMode: EKAttributes.DisplayMode.inferred
    )
}
