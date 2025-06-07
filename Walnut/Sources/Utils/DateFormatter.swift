//
//  DateFormatter.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//

import Foundation

// MARK: - Helper Extensions
extension DateFormatter {
    static let mediumStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
