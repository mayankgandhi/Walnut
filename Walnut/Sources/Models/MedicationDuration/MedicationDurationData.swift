//
//  MedicationDurationData.swift
//  Walnut
//
//  Created by Mayank Gandhi on 06/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import AIKit

// MARK: - MedicationDuration Struct
struct MedicationDurationData: Codable, Hashable {
    
    let type: DurationType
    let value: Int?
    let date: Date?
    
    enum DurationType: String, Codable, CaseIterable {
        case days, weeks, months, ongoing, asNeeded, untilFollowUp
    }
    
    // Convert to enum case
    func toEnum() -> MedicationDuration? {
        switch type {
            case .days:
                guard let value = value else {
                    return nil
                }
                return .days(value)
                
            case .weeks:
                guard let value = value else {
                    return nil
                }
                return .weeks(value)
                
            case .months:
                guard let value = value else {
                    return nil
                }
                return .months(value)
                
            case .ongoing:
                return .ongoing
                
            case .asNeeded:
                return .asNeeded
                
            case .untilFollowUp:
                guard let date = date else {
                    return nil
                }
                return .untilFollowUp(date)
        }
    }
}
