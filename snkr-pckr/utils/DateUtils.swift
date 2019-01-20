//
//  DateUtils.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 20/01/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import Foundation

class DateUtils {
    static let NOT_WORN_YET_LABEL = "Not worn yet."
    static let DATE_FORMAT = "dd MMM"
    static let TIME_FORMAT = "HH:mm"
    static let DATE_FORMATTER: DateFormatter = DateFormatter()
    static let TIME_FORMATTER: DateFormatter = DateFormatter()
    
    class func formatDate(lastWornDate: Date?) -> String {
        if lastWornDate == nil {
            return NOT_WORN_YET_LABEL
        }
        
        DATE_FORMATTER.dateFormat = DATE_FORMAT
        TIME_FORMATTER.dateFormat = TIME_FORMAT
        
        return String(format: "Worn on %@ at %@", DATE_FORMATTER.string(from: lastWornDate!), TIME_FORMATTER.string(from: lastWornDate!))
    }
}
