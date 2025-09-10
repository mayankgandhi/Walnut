//
//  AppearanceView.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct AppearanceView: View {
    @State private var viewModel: AppearanceViewModel
    private let patient: Patient
    
    init(patient: Patient) {
        self.patient = patient
        self._viewModel = State(wrappedValue: AppearanceViewModel(patient: patient))
    }
    
    var body: some View {
        MenuListItem(
            icon: viewModel.menuItem.icon,
            title: viewModel.menuItem.title,
            subtitle: viewModel.menuItem.subtitle,
            iconColor: viewModel.menuItem.iconColor
        ) {
            viewModel.presentAppearanceSettings()
        }
        // TODO: Add sheet presentation when AppearanceSettingsView is implemented
        // .sheet(isPresented: $viewModel.showAppearanceSettings, onDismiss: {
        //     viewModel.dismissAppearanceSettings()
        // }) {
        //     AppearanceSettingsView()
        // }
    }
}

#Preview {
    AppearanceView(patient: .samplePatient)
}