//
//  EditProfileView.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct EditProfileView: View {
    @State private var viewModel: EditProfileViewModel
    private let patient: Patient
    
    init(patient: Patient) {
        self.patient = patient
        self._viewModel = State(wrappedValue: EditProfileViewModel(patient: patient))
    }
    
    var body: some View {
        MenuListItem(
            icon: viewModel.menuItem.icon,
            title: viewModel.menuItem.title,
            subtitle: viewModel.menuItem.subtitle,
            iconColor: viewModel.menuItem.iconColor
        ) {
            viewModel.presentEditSheet()
        }
        .sheet(isPresented: $viewModel.showEditPatient, onDismiss: {
            viewModel.dismissEditSheet()
        }) {
            PatientEditor(patient: patient)
        }
    }
}

#Preview {
    EditProfileView(patient: .samplePatient)
}