//
//  AddManuallyButton.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

public struct AddPrescriptionManuallyButton: View {
    
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
            PrescriptionEditor(patient: patient, medicalCase: medicalCase)
        }
    }
}


public struct AddBiomarkerReportManuallyButton: View {
    
    let patient: Patient?
    let medicalCase: MedicalCase?
    @State var store: DocumentPickerStore
    @State var presentDocumentPicker: DocumentType?
    
    // Convenience initializers for different workflows
    init(patient: Patient, store: DocumentPickerStore) {
        self.medicalCase = nil
        self.patient = patient
        self.store = store
    }
    
    init(medicalCase: MedicalCase, store: DocumentPickerStore) {
        self.medicalCase = medicalCase
        self.patient = nil
        self.store = store
    }
    
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
            if let medicalCase {
                BloodReportEditor(medicalCase: medicalCase)
            } else if let patient = patient {
                BloodReportEditor(patient: patient)
            }
        }
    }
}

