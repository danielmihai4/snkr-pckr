//
//  FormStyle.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 03/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import SwiftEntryKit

class NewCategoryPopupStyle {
    
    static let titleStyle = EKProperty.LabelStyle(
            font: MainFont.demiBold.with(size: 20),
            color: EKColor(light: Colors.cadetGrey, dark: Colors.cadetGrey),
            displayMode: EKAttributes.DisplayMode.inferred)
    
    static let textStyle = EKProperty.LabelStyle(
            font: MainFont.regular.with(size: 14),
            color: EKColor(light: Colors.cadetGrey, dark: Colors.cadetGrey),
            displayMode: EKAttributes.DisplayMode.inferred)    
 
    static let buttonStyle = EKProperty.LabelStyle(
            font: MainFont.regular.with(size: 16),
            color: EKColor(light: Colors.cadetGrey, dark: Colors.cadetGrey))
    
    static let placeholderStyle = EKProperty.LabelStyle(
            font: MainFont.regular.with(size: 14),
            color: EKColor(light: Colors.cadetGrey.withAlphaComponent(0.5), dark: Colors.cadetGrey.withAlphaComponent(0.5)))
}
