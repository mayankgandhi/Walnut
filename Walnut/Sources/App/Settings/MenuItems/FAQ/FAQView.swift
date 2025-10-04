//
//  FAQView.swift
//  Walnut
//
//  Created by Claude Code on 10/04/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct FAQView: View {
    @State private var viewModel: FAQViewModel
    private let patient: Patient

    init(patient: Patient) {
        self.patient = patient
        self._viewModel = State(wrappedValue: FAQViewModel(patient: patient))
    }

    var body: some View {
        MenuListItem(
            icon: viewModel.menuItem.icon,
            title: viewModel.menuItem.title,
            subtitle: viewModel.menuItem.subtitle,
            iconColor: viewModel.menuItem.iconColor
        ) {
            viewModel.presentFAQ()
        }
        .sheet(isPresented: $viewModel.showFAQ) {
            FAQDetailView(viewModel: viewModel)
        }
    }
}

// MARK: - FAQ Detail View
struct FAQDetailView: View {
    @State var viewModel: FAQViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Medical Disclaimer")
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HealthCard {
                VStack(alignment: .leading, spacing: Spacing.small) {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)

                    Text("This is a personal health journal app, not a medical or health tracking app. It is not intended to diagnose, treat, cure, or prevent any disease or medical condition.")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("Please consult your personal medical health practitioners for any medical advice, diagnosis, or treatment. Always seek the advice of qualified health providers with any questions you may have regarding a medical condition.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.medium) {
                    ForEach(viewModel.faqs) { faq in
                        FAQItemView(item: faq)
                    }
                    
                    disclaimerSection
                    .padding(.horizontal, Spacing.medium)
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.vertical, Spacing.large)
            }
            .navigationTitle("FAQ")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - FAQ Item View
struct FAQItemView: View {
    let item: FAQItem
    @State private var isExpanded = false

    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.small) {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(alignment: .top, spacing: Spacing.medium) {
                        VStack(alignment: .leading, spacing: Spacing.xs) {
                            Text(item.question)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    Text(item.answer)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

#Preview {
    FAQView(patient: .samplePatient)
}

#Preview("FAQ Detail") {
    FAQDetailView(viewModel: FAQViewModel(patient: .samplePatient))
}
