//
//  DatePickerSheet.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct DatePickerSheet: View {
    @Binding var selectedDate: Date?
    let onDismiss: () -> Void
    
    @State private var tempDate = Date()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                DatePicker(
                    "Date of Birth",
                    selection: $tempDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Date of Birth")
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
            tempDate = selectedDate ?? Date()
        }
    }
}
