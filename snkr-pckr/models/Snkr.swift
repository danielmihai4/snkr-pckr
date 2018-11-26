//
//  Snkr.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 18/11/2018.
//  Copyright © 2018 Daniel Mihai. All rights reserved.
//

import Foundation
import UIKit

public class Snkr {
    let name: String
    let colorway: String
    let pic: UIImage
    var lastWornDate: Date?
    
    public init(name: String, colorway: String, lastWornDate: Date?, pic: UIImage) {
        self.name = name
        self.colorway = colorway
        self.lastWornDate = lastWornDate
        self.pic = pic
    }
}
