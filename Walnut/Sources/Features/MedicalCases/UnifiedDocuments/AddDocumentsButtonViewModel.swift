//
//  AddDocumentsButtonViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI
import SwiftData
import Observation

@Observable
class AddDocumentsButtonViewModel {

    var showHealthRecordSelector: Bool = false
    var showModularDocumentPicker: Bool = false

    func showAddDocumentSheet() {
        showHealthRecordSelector = true
    }
    
}
