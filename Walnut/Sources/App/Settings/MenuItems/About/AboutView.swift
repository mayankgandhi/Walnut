//
//  AboutView.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct AboutView: View {
    @State private var viewModel: AboutViewModel
    private let patient: Patient
    
    init(patient: Patient) {
        self.patient = patient
        self._viewModel = State(wrappedValue: AboutViewModel(patient: patient))
    }
    
    var body: some View {
        MenuListItem(
            icon: viewModel.menuItem.icon,
            title: viewModel.menuItem.title,
            subtitle: viewModel.menuItem.subtitle,
            iconColor: viewModel.menuItem.iconColor
        ) {
            viewModel.presentAboutSheet()
        }
        .sheet(isPresented: $viewModel.showAboutSheet, onDismiss: {
            viewModel.dismissAboutSheet()
        }) {
            AboutSheet()
                .presentationDetents([.medium])
                .presentationCornerRadius(Spacing.large)
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    AboutView(patient: .samplePatient)
}