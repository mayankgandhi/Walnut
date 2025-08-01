//
//  PrescriptionDetailView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 12/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PrescriptionDetailView: View {
    
    let prescription: Prescription
    @Environment(\.dismiss) private var dismiss
    @State private var showingMedicationEditor = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header Card
                    headerCard
                    
                    // Follow-up Card
                    if prescription.followUpDate != nil || !(prescription.followUpTests?.isEmpty ?? false) {
                        followUpCard
                    }
                    
                    // Notes Card
                    if let notes = prescription.notes, !notes.isEmpty {
                        notesCard
                    }
                    
                    // Document Card
                    if let document = prescription.document {
                        documentCard(document: document)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Prescription Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
            .sheet(isPresented: $showingMedicationEditor) {
                PrescriptionMedicationEditor(prescription: prescription)
            }
        }
    }
    
    // MARK: - Header Card
    private var headerCard: some View {
        VStack(spacing: 16) {
            // Doctor and Facility Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let doctorName = prescription.doctorName {
                        Text(doctorName)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    if let facilityName = prescription.facilityName {
                        Text(facilityName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Health Cross Icon
                Image(systemName: "cross.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white, .green)
            }
            
            Divider()
            
            // Date Information
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Issued Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text(prescription.dateIssued, style: .date)
                        .font(.headline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Medications")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Text("\(prescription.medications.count)")
                        .font(.headline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    
    // MARK: - Follow-up Card
    private var followUpCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Follow-up")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if let followUpDate = prescription.followUpDate {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Appointment")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                        
                        Text(followUpDate, style: .date)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
                .padding(12)
                .background(Color.purple.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            if let followUpTests = prescription.followUpTests {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Required Tests")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    ForEach(followUpTests, id: \.self) { test in
                        HStack {
                            Image(systemName: "checkmark.circle")
                                .font(.caption)
                                .foregroundColor(.purple)
                            
                            Text(test)
                                .font(.subheadline)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Notes Card
    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "note.text")
                    .font(.title2)
                    .foregroundColor(.indigo)
                
                Text("Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(prescription.notes ?? "")
                .font(.subheadline)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Document Card
    private func documentCard(document: Document) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text("Document")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View") {
                    // Handle document viewing
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.red)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.fileName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                    
                    Text("PDF Document • \(document.fileSize) KB")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right.square")
                    .font(.title2)
                    .foregroundColor(.red)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
}
