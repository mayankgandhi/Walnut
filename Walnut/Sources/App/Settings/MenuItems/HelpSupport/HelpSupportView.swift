//
//  HelpSupportView.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct HelpSupportView: View {
    @State private var viewModel: HelpSupportViewModel
    private let patient: Patient
    
    init(patient: Patient) {
        self.patient = patient
        self._viewModel = State(wrappedValue: HelpSupportViewModel(patient: patient))
    }
    
    var body: some View {
        MenuListItem(
            icon: viewModel.menuItem.icon,
            title: viewModel.menuItem.title,
            subtitle: viewModel.menuItem.subtitle,
            iconColor: viewModel.menuItem.iconColor
        ) {
            viewModel.presentHelpSupport()
        }
        // TODO: Add sheet presentation when HelpSupportView is implemented
        // .sheet(isPresented: $viewModel.showHelpSupport, onDismiss: {
        //     viewModel.dismissHelpSupport()
        // }) {
        //     HelpSupportView()
        // }
    }
}

#Preview {
    HelpSupportView(patient: .samplePatient)
}