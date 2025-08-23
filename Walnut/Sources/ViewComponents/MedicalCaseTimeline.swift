//
//  MedicalCaseTimeline.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

// MARK: - Timeline Event Data Model

struct TimelineEvent: Identifiable {
    let id = UUID()
    let icon: String
    let color: Color
    let title: String
    let subtitle: String?
    let date: Date
}

// MARK: - Timeline Event Provider Protocol

protocol TimelineEventProvider {
    func generateTimelineEvents() -> [TimelineEvent]
}

// MARK: - Generic Timeline Component

struct Timeline: View {
    let title: String
    let icon: String
    let events: [TimelineEvent]
    
    init(title: String, icon: String, events: [TimelineEvent]) {
        self.title = title
        self.icon = icon
        self.events = events
    }
    
    init<Provider: TimelineEventProvider>(title: String, icon: String, provider: Provider) {
        self.title = title
        self.icon = icon
        self.events = provider.generateTimelineEvents()
    }
    
    var body: some View {
        HealthCard(padding: Spacing.large) {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                // Section Header
                timelineHeader
                
                // Timeline Items
                timelineEvents
            }
        }
    }
}

// MARK: - Timeline Private Views

private extension Timeline {
    
    var timelineHeader: some View {
        HStack(spacing: Spacing.small) {
            ZStack {
                Circle()
                    .fill(Color.healthPrimary.opacity(0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.healthPrimary)
            }
            
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
            
            Spacer()
        }
    }
    
    var timelineEvents: some View {
        VStack(spacing: Spacing.medium) {
            let sortedEvents = events.sorted(by: { $0.date < $1.date })
            
            ForEach(Array(sortedEvents.enumerated()), id: \.element.id) { index, event in
                TimelineItemView(
                    event: event,
                    isFirst: index == 0,
                    isLast: index == sortedEvents.count - 1
                )
            }
        }
    }
}

// MARK: - Medical Case Timeline Event Provider

struct MedicalCaseTimelineEventProvider: TimelineEventProvider {
    let medicalCase: MedicalCase
    
    func generateTimelineEvents() -> [TimelineEvent] {
        var events: [TimelineEvent] = []
        
        // Case creation event
        events.append(TimelineEvent(
            icon: "plus.circle.fill",
            color: .healthSuccess,
            title: "Case Created",
            subtitle: "Initial patient consultation",
            date: medicalCase.createdAt
        ))
        
        // Prescription events
        let prescriptionEvents = medicalCase.prescriptions
            .sorted(by: { $0.dateIssued < $1.dateIssued })
            .map { prescription in
                TimelineEvent(
                    icon: "pills.fill",
                    color: .blue,
                    title: "Prescription Added",
                    subtitle: prescription.doctorName.map { "Dr. \($0)" } ?? "New medication prescribed",
                    date: prescription.dateIssued
                )
            }
        events.append(contentsOf: prescriptionEvents)
        
        // Blood report events
        let bloodReportEvents = medicalCase.bloodReports
            .sorted(by: { $0.resultDate < $1.resultDate })
            .map { bloodReport in
                let abnormalCount = bloodReport.testResults.filter(\.isAbnormal).count
                let subtitle = abnormalCount > 0 ? 
                    "\(bloodReport.testName) - \(abnormalCount) abnormal results" : 
                    "\(bloodReport.testName) - All normal"
                
                return TimelineEvent(
                    icon: "drop.fill",
                    color: abnormalCount > 0 ? .healthError : .healthSuccess,
                    title: "Blood Report Added",
                    subtitle: subtitle,
                    date: bloodReport.resultDate
                )
            }
        events.append(contentsOf: bloodReportEvents)
        
        // Case update event (if different from creation)
        if medicalCase.updatedAt != medicalCase.createdAt {
            events.append(TimelineEvent(
                icon: "pencil.circle.fill",
                color: .healthPrimary,
                title: "Case Updated",
                subtitle: "Recent modifications",
                date: medicalCase.updatedAt
            ))
        }
        
        return events
    }
}

// MARK: - Medical Case Timeline Component

struct MedicalCaseTimeline: View {
    let medicalCase: MedicalCase
    
    var body: some View {
        Timeline(
            title: "Timeline",
            icon: "clock.arrow.circlepath",
            provider: MedicalCaseTimelineEventProvider(medicalCase: medicalCase)
        )
    }
}


// MARK: - Timeline Item View

struct TimelineItemView: View {
    let event: TimelineEvent
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: Spacing.medium) {
            // Timeline marker
            timelineMarker
            
            // Content
            eventContent
            
            Spacer()
        }
    }
}

// MARK: - Timeline Item Private Views

private extension TimelineItemView {
    
    var timelineMarker: some View {
        VStack(spacing: 0) {
            if !isFirst {
                Rectangle()
                    .fill(Color(UIColor.separator))
                    .frame(width: 2, height: 20)
            }
            
            ZStack {
                Circle()
                    .fill(event.color.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                Image(systemName: event.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(event.color)
            }
            
            if !isLast {
                Rectangle()
                    .fill(Color(UIColor.separator))
                    .frame(width: 2, height: 20)
            }
        }
    }
    
    var eventContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.title)
                .font(.callout.weight(.medium))
                .foregroundStyle(.primary)
            
            if let subtitle = event.subtitle {
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            
            Text(event.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.large) {
        // Generic Timeline with custom events
        Timeline(
            title: "Custom Timeline",
            icon: "star.circle.fill",
            events: [
                TimelineEvent(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: "Task Completed",
                    subtitle: "Successfully finished the task",
                    date: Date().addingTimeInterval(-3600)
                ),
                TimelineEvent(
                    icon: "exclamationmark.triangle.fill",
                    color: .orange,
                    title: "Warning Issued",
                    subtitle: "System detected an issue",
                    date: Date()
                )
            ]
        )
        
        // Medical Case Timeline
        MedicalCaseTimeline(medicalCase: MedicalCase.sampleCase)
    }
    .padding()
}