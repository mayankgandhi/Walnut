//
//  AddManuallyButton.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

public struct AddManuallyButton: View {
    
    let patient: Patient
    let medicalCase: MedicalCase
    @State var store: DocumentPickerStore
    @State var presentDocumentPicker: DocumentType?
    
    public var body: some View {
        Button {
            guard let selectedDocumentType = store.selectedDocumentType else {
                return
            }
            presentDocumentPicker = selectedDocumentType
        } label: {
            HStack {
                Image(systemName: "square.and.pencil")
                    .font(.title2)
                Text("Add Manually")
                    .font(.headline)
            }
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .sheet(item: $presentDocumentPicker) { documentType in
            switch documentType {
            case .prescription:
                    PrescriptionEditor(patient: patient, medicalCase: medicalCase)
            case .labResult:
                BloodReportEditor(medicalCase: medicalCase)
                
            default:
                 EmptyView()
            }
        }
    }
}
