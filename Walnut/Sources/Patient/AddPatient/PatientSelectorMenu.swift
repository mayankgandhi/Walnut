//
//  PatientSelectorMenu.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

extension Patient {
    var fullName: String {
        let first = firstName ?? ""
        let last = lastName ?? ""
        return "\(first) \(last)".trimmingCharacters(in: .whitespaces)
    }
}
