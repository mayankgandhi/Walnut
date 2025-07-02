//
//  MedicalCaseDetailView 2.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//


import SwiftUI

// Complete Medical Case Detail View
struct MedicalCaseDetailView: View {
    let medicalCase: MedicalCaseData
    let documents: [DocumentData]
    
    @State private var showAddDocument = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Card
                MedicalCaseHeaderCard(medicalCase: medicalCase)
                    .padding(.horizontal)
                
                // Documents Section
                MedicalCaseDocumentsSection(documents: documents)
                
                // Additional sections can be added here
                // Lab Results Section
                // Calendar Events Section
                // Medical Records Section
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showAddDocument = true
                    } label: {
                        Label("Add Document", systemImage: "doc.badge.plus")
                    }
                    
                    Button {
                        // Add calendar event
                    } label: {
                        Label("Schedule Appointment", systemImage: "calendar.badge.plus")
                    }
                    
                    Button {
                        // Add lab result
                    } label: {
                        Label("Add Lab Result", systemImage: "flask")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddDocument) {
            DocumentPickerView()
        }
    }
}

// Document Picker View
struct DocumentPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDocumentType = "Prescription"
    
    let documentTypes = ["Prescription", "Lab Result", "Diagnosis", "Notes", "Imaging"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Document Type Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Document Type")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(documentTypes, id: \.self) { type in
                                DocumentTypeButton(
                                    type: type,
                                    isSelected: selectedDocumentType == type
                                ) {
                                    selectedDocumentType = type
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Upload Area
                VStack(spacing: 16) {
                    Image(systemName: "doc.badge.arrow.up.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.blue)
                    
                    Text("Tap to select a document")
                        .font(.headline)
                    
                    Text("Supports PDF, JPG, PNG, and HEIC files")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .background(Color.blue.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                        .foregroundColor(.blue.opacity(0.3))
                )
                .cornerRadius(16)
                .padding(.horizontal)
                .onTapGesture {
                    // Present document picker
                }
                
                Spacer()
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Document Type Button
struct DocumentTypeButton: View {
    let type: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: typeIcon)
                Text(type)
            }
            .font(.subheadline)
            .fontWeight(isSelected ? .semibold : .medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? typeColor : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
        }
    }
    
    private var typeIcon: String {
        switch type.lowercased() {
        case "prescription":
            return "pills.fill"
        case "lab result":
            return "flask.fill"
        case "diagnosis":
            return "stethoscope"
        case "notes":
            return "note.text"
        case "imaging":
            return "camera.fill"
        default:
            return "doc.fill"
        }
    }
    
    private var typeColor: Color {
        switch type.lowercased() {
        case "prescription":
            return .blue
        case "lab result":
            return .red
        case "diagnosis":
            return .purple
        case "notes":
            return .orange
        case "imaging":
            return .green
        default:
            return .gray
        }
    }
}

#Preview(body: {
    MedicalCaseDetailView(medicalCase: MedicalCaseData.randomCase(),
                          documents:  [
                            DocumentData(
                                id: UUID(),
                                fileName: "Blood_Test_Results_2024.pdf",
                                fileURL: URL(string: "file://")!,
                                documentType: "Lab Result",
                                documentDate: Date().addingTimeInterval(-86400 * 7),
                                uploadDate: Date().addingTimeInterval(-86400 * 2),
                                fileSize: 245760
                            ),
                            DocumentData(
                                id: UUID(),
                                fileName: "Prescription_Cardiology.pdf",
                                fileURL: URL(string: "file://")!,
                                documentType: "Prescription",
                                documentDate: Date().addingTimeInterval(-86400 * 3),
                                uploadDate: Date().addingTimeInterval(-86400 * 1),
                                fileSize: 123456
                            ),
                            DocumentData(
                                id: UUID(),
                                fileName: "Chest_XRay_Report.jpg",
                                fileURL: URL(string: "file://")!,
                                documentType: "Imaging",
                                documentDate: Date().addingTimeInterval(-86400 * 14),
                                uploadDate: Date().addingTimeInterval(-86400 * 10),
                                fileSize: 2097152
                            )
                          ])
})
