//
//  DateExtension.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

public extension Date {
    /// Formats date for file subtitles
    var fileSubtitleFormat: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            formatter.timeStyle = .short
            return "Today • \(formatter.string(from: self))"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else if calendar.dateInterval(of: .weekOfYear, for: Date())?.contains(self) == true {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        } else {
            formatter.dateStyle = .medium
            return formatter.string(from: self)
        }
    }
}
