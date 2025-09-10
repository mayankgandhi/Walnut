//
//  ICloudSyncView.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct ICloudSyncView: View {
    @State private var viewModel: ICloudSyncViewModel
    private let patient: Patient
    
    init(patient: Patient) {
        self.patient = patient
        self._viewModel = State(wrappedValue: ICloudSyncViewModel(patient: patient))
    }
    
    var body: some View {
        MenuListItem(
            icon: viewModel.menuItem.icon,
            title: viewModel.menuItem.title,
            subtitle: viewModel.menuItem.subtitle,
            iconColor: viewModel.menuItem.iconColor
        ) {
            viewModel.presentICloudSync()
        }
        .sheet(isPresented: $viewModel.showICloudSync, onDismiss: {
            viewModel.dismissICloudSync()
        }) {
            DSBottomSheet(
                title: "iCloud Sync",
                subtitle: "Keep your medical data synchronized across all your devices",
                onDismiss: {
                    viewModel.dismissICloudSync()
                }
            ) {
                iCloudSyncSettingsView()
            }
            .presentationDetents([.height(600), .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ICloudSyncView(patient: .samplePatient)
}