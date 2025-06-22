//
//  OverviewTabView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Overview Tab View
struct OverviewTabView: View {
    let medicalCase: MedicalCase
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Case Information Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Case Information")
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(label: "Title", value: medicalCase.title ?? "N/A")
                        InfoRow(label: "Created", value: medicalCase.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")
                        InfoRow(label: "Last Updated", value: medicalCase.updatedAt?.formatted(date: .abbreviated, time: .shortened) ?? "N/A")
                        InfoRow(label: "Follow-up Required", value: medicalCase.followUpRequired ? "Yes" : "No")
                    }
                }
                .padding(16)
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Notes Card
                if let notes = medicalCase.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text(notes)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(16)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
                
                // Treatment Plan Card
                if let treatmentPlan = medicalCase.treatmentPlan, !treatmentPlan.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Treatment Plan")
                            .font(.headline)
                            .foregroundColor(.textPrimary)
                        
                        Text(treatmentPlan)
                            .font(.body)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(16)
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.textPrimary)
        }
    }
}

// MARK: - Placeholder Tab Views
struct MedicalRecordsTabView: View {
    let records: [MedicalRecord]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(records, id: \.id) { record in
                    RecordCard(record: record)
                }
            }
            .padding(16)
        }
    }
}

struct LabResultsTabView: View {
    let labResults: [LabResult]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(labResults, id: \.id) { labResult in
                    LabResultCard(labResult: labResult)
                }
            }
            .padding(16)
        }
    }
}

struct DocumentsTabView: View {
    let documents: [Document]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(documents, id: \.id) { document in
                    DocumentCard(document: document)
                }
            }
            .padding(16)
        }
    }
}

struct CalendarTabView: View {
    let events: [CalendarEvent]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(events, id: \.id) { event in
                    CalendarEventCard(event: event)
                }
            }
            .padding(16)
        }
    }
}


// MARK: - Card Components
struct RecordCard: View {
    let record: MedicalRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.title ?? "Medical Record")
                .font(.headline)
            
            if let summary = record.summary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            Text(record.dateRecorded?.formatted(date: .abbreviated, time: .shortened) ?? "")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

struct LabResultCard: View {
    let labResult: LabResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(labResult.testName ?? "Lab Test")
                .font(.headline)
            
            if let labName = labResult.labName {
                Text(labName)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            Text(labResult.resultDate?.formatted(date: .abbreviated, time: .shortened) ?? "")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

struct DocumentCard: View {
    let document: Document
    
    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(document.fileName ?? "Document")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(document.documentType ?? "Unknown Type")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            
            Spacer()
            
            Text(document.uploadDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

struct CalendarEventCard: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack {
            VStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title ?? "Event")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let location = event.location {
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            Text(event.startDate?.formatted(date: .abbreviated, time: .shortened) ?? "")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}
