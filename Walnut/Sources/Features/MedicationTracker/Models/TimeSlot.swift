//
//  TimeSlot.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI

/// Time slots for organizing medications throughout the day
enum TimeSlot: String, CaseIterable, Identifiable {
    case morning = "morning"
    case midday = "midday" 
    case afternoon = "afternoon"
    case evening = "evening"
    case night = "night"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .midday: return "Midday"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }
    
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .midday: return "sun.max.fill"
        case .afternoon: return "sun.haze.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .morning: return .orange
        case .midday: return .yellow
        case .afternoon: return .blue
        case .evening: return .purple
        case .night: return .indigo
        }
    }
    
    var timeRange: (start: Int, end: Int) {
        switch self {
        case .morning: return (6, 11)   // 6 AM - 11 AM
        case .midday: return (11, 14)   // 11 AM - 2 PM
        case .afternoon: return (14, 17) // 2 PM - 5 PM
        case .evening: return (17, 21)   // 5 PM - 9 PM
        case .night: return (21, 6)      // 9 PM - 6 AM (next day)
        }
    }
}
