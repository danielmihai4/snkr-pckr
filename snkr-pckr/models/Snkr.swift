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
    let id: UUID
    var name: String
    var colorway: String
    var pic: UIImage?
    var smallPic: UIImage?
    var lastWornDate: Date?
    var isClean: Bool?
    
    public init(id: UUID, name: String, colorway: String, lastWornDate: Date?, isClean: Bool, pic: UIImage?, smallPic: UIImage?) {
        self.id = id
        self.name = name
        self.colorway = colorway
        self.lastWornDate = lastWornDate
        self.isClean = isClean
        self.pic = pic
        self.smallPic = smallPic
    }
}
