//
//  Fonts.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 03/08/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

typealias MainFont = Fonts.AvenirNext

enum Fonts {
    enum AvenirNext: String {
        case bold = "bold"
        case boldItalic = "BoldItalic"
        case demiBold = "DemiBold"
        case demiBoldItalic = "DemiBoldItalic"
        case heavy = "Heavy"
        case heavyItalic = "HeavyItalic"
        case italic = "Italic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"
        case regular = "Regular"
        case ultraLight = "UltraLight"
        case ultraLightItalic = "UltraLightItalic"
        
        func with(size: CGFloat) -> UIFont {
            return UIFont(name: "AvenirNext-\(rawValue)", size: size)!
        }
    }
}

