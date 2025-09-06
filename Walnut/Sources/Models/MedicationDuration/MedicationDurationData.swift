//
//  MedicationDurationData.swift
//  Walnut
//
//  Created by Mayank Gandhi on 06/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

// MARK: - MedicationDuration Struct
struct MedicationDurationData: Codable, Hashable {

    let type: DurationType
    let value: Int?
    let date: Date?
    
    enum DurationType: String, Codable, CaseIterable {
        case days, weeks, months, ongoing, asNeeded, untilFollowUp
    }
    
    // Convenience initializers for each duration type
    static func days(_ days: Int) -> MedicationDurationData {
        return MedicationDurationData(type: .days, value: days, date: nil)
    }
    
    static func weeks(_ weeks: Int) -> MedicationDurationData {
        return MedicationDurationData(type: .weeks, value: weeks, date: nil)
    }
    
    static func months(_ months: Int) -> MedicationDurationData {
        return MedicationDurationData(type: .months, value: months, date: nil)
    }
    
    static func ongoing() -> MedicationDurationData {
        return MedicationDurationData(type: .ongoing, value: nil, date: nil)
    }
    
    static func asNeeded() -> MedicationDurationData {
        return MedicationDurationData(type: .asNeeded, value: nil, date: nil)
    }
    
    static func untilFollowUp(_ date: Date) -> MedicationDurationData {
        return MedicationDurationData(type: .untilFollowUp, value: nil, date: date)
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
