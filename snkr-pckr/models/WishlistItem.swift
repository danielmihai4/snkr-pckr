//
//  WishlistItem.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 21/07/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

import Foundation
import UIKit

public class WishlistItem {
    let id: UUID
    let name: String
    let colorway: String
    let price: NSDecimalNumber
    let releaseDate: Date
    let pic: UIImage
    
    public init(id: UUID, name: String, colorway: String, price: NSDecimalNumber, releaseDate: Date, pic: UIImage) {
        self.id = id
        self.name = name
        self.colorway = colorway
        self.price = price
        self.releaseDate = releaseDate
        self.pic = pic
    }
}
