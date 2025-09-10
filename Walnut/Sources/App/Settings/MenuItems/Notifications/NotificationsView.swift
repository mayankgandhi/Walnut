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
    @State private var viewModel: NotificationsViewModel
    private let patient: Patient
    
    init(patient: Patient) {
        self.patient = patient
        self._viewModel = State(wrappedValue: NotificationsViewModel(patient: patient))
    }
    
    var body: some View {
        MenuListItem(
            icon: viewModel.menuItem.icon,
            title: viewModel.menuItem.title,
            subtitle: viewModel.menuItem.subtitle,
            iconColor: viewModel.menuItem.iconColor
        ) {
            viewModel.presentNotificationSettings()
        }
        .sheet(isPresented: $viewModel.showNotificationSettings, onDismiss: {
            viewModel.dismissNotificationSettings()
        }) {
            DSBottomSheet(title: "Notifications"){
                viewModel.notificationSettingsBottomSheetContent
            } content: {
                NotificationSettingsView()
            }
            .presentationDetents([.height(700), .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NotificationsView(patient: .samplePatient)
}