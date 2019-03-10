//
//  Category.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 09/03/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation
import UIKit

public class Category {
    let id: UUID
    let name: String
    var snkrs: [Snkr]
    
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
        self.snkrs = []
    }
}
