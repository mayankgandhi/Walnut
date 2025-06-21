//
//  DatePickerSheet.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date?
    let onDismiss: () -> Void
    @State private var tempDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker(
                        "Date of Birth",
                        selection: $tempDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                }
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedDate = tempDate
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            if let date = selectedDate {
                tempDate = date
            }
        }
    }
}
