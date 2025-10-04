//
//  HelpSupportView.swift
//  Walnut
//
//  Created by Claude Code on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import MessageUI

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
        .sheet(isPresented: $viewModel.showMailCompose) {
            MailComposeView(
                recipients: ["walnut@mayankgandhi.com"],
                subject: "Help & Support",
                onDismiss: { viewModel.dismissMailCompose() }
            )
        }
    }
}

// MARK: - Mail Compose Wrapper
struct MailComposeView: UIViewControllerRepresentable {
    let recipients: [String]
    let subject: String
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailCompose = MFMailComposeViewController()
        mailCompose.setToRecipients(recipients)
        mailCompose.setSubject(subject)
        mailCompose.mailComposeDelegate = context.coordinator
        return mailCompose
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            onDismiss()
        }
    }
}

#Preview {
    HelpSupportView(patient: .samplePatient)
}