//
//  NotificationsView.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct NotificationsView: View {
    @State private var showNotificationReview = false
    private let patient: Patient
    
    init(patient: Patient) {
        self.patient = patient
    }
    
    var body: some View {
        
        MenuListItem(
            icon: "bell.badge",
            title: "Upcoming Reminders",
            subtitle: "View your medication schedule",
            iconColor: .healthSuccess
        ) {
            showNotificationReview = true
        }
        
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        
        .sheet(isPresented: $showNotificationReview) {
            NotificationReviewView()
        }
    }
}

#Preview {
    NotificationsView(patient: .samplePatient)
}
