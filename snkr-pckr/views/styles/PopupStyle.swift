//
//  FormStyle.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 03/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import SwiftEntryKit

class PopupStyle {
    
    static let titleStyle = EKProperty.LabelStyle(
            font: MainFont.demiBold.with(size: 20),
            color: EKColor(light: UIColor.white, dark: UIColor.white),
            displayMode: EKAttributes.DisplayMode.inferred)
    
    static let textStyle = EKProperty.LabelStyle(
            font: MainFont.regular.with(size: 14),
            color: EKColor(light: UIColor.white, dark: UIColor.white),
            displayMode: EKAttributes.DisplayMode.inferred)    
 
    static let buttonStyle = EKProperty.LabelStyle(
            font: MainFont.regular.with(size: 16),
            color: EKColor(light: UIColor.white, dark: UIColor.white))
    
    static let placeholderStyle = EKProperty.LabelStyle(
            font: MainFont.regular.with(size: 14),
            color: EKColor(light: UIColor.white.withAlphaComponent(0.5), dark: UIColor.white.withAlphaComponent(0.5)))
}
