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
    static let NO_RELEASE_DATE_LABEL = "No release date yet."
    static let DATE_FORMAT = "dd MMM"
    static let DATE_FORMAT_WITH_YEAR = "dd MMM yyyy"
    static let DATE_FORMAT_DAY = "dd"
    static let DATE_FORMAT_MONTH = "MMM"
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
    
    class func formatReleaseDateDay(releaseDate: Date?) -> String {
        return formatReleaseDate(releaseDate: releaseDate, format: DATE_FORMAT_DAY)
    }
    
    class func formatReleaseDateMonth(releaseDate: Date?) -> String {
        return formatReleaseDate(releaseDate: releaseDate, format: DATE_FORMAT_MONTH)
    }
    
    private class func formatReleaseDate(releaseDate: Date?, format: String) -> String {
        if releaseDate == nil {
            return NO_RELEASE_DATE_LABEL
        }
        
        DATE_FORMATTER.dateFormat = format
        
        return String(format: "%@", DATE_FORMATTER.string(from: releaseDate!))
    }
}
