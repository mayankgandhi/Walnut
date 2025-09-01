//
//  MedicalSpecialtySelector.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct MedicalSpecialtySelector: View {
    @Binding var selectedSpecialty: MedicalSpecialty?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.medium) {
            HealthCardHeader(title: "Select Medical Specialty")
            
            LazyVGrid(
                columns: [
                    .init(
                        .flexible(minimum: 20, maximum: .infinity),
                        spacing: Spacing.medium,
                        alignment: .leading
                    ),
                    .init(
                        .flexible(minimum: 20, maximum: .infinity),
                        spacing: Spacing.medium,
                        alignment: .leading
                    )
                ],
                alignment: .leading,
                spacing: Spacing.medium
            ) {
                ForEach(MedicalSpecialty.allCases, id: \.self) { specialty in
                    Button {
                        selectedSpecialty = specialty
                    } label: {
                        MedicalSpecialtyButton(
                            specialty: specialty,
                            isSelected: selectedSpecialty == specialty
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, Spacing.medium)
    }
}

struct MedicalSpecialtyButton: View {
    let specialty: MedicalSpecialty
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.small) {
            HStack {
                Image(specialty.icon)
                    .resizable()
                    .frame(width: 48, height: 48)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.healthPrimary)
                }
            }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(specialty.rawValue)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(Spacing.medium)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(strokeColor, lineWidth: isSelected ? 2 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .healthPrimary.opacity(0.05)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private var strokeColor: Color {
        if isSelected {
            return .healthPrimary
        } else {
            return Color(.systemGray5)
        }
    }
    
    private var iconColor: Color {
        if isSelected {
            return .healthPrimary
        } else {
            return .secondary
        }
    }
}

struct MedicalSpecialtyBottomSheet: View {
    @Binding var selectedSpecialty: MedicalSpecialty?
    @Binding var isPresented: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                MedicalSpecialtySelector(selectedSpecialty: $selectedSpecialty)
            }
            .navigationTitle("Medical Specialty")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if selectedSpecialty != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isPresented = false
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(Spacing.large)
        .interactiveDismissDisabled(false)
    }
}

#Preview("Medical Specialty Selector") {
    @Previewable
    @State var selectedSpecialty: MedicalSpecialty? = .cardiologist
    
    VStack {
        MedicalSpecialtySelector(selectedSpecialty: $selectedSpecialty)
        Spacer()
    }
    .padding()
}

#Preview("Medical Specialty Bottom Sheet") {
    @State var selectedSpecialty: MedicalSpecialty? = nil
    @State var isPresented = true
    
    return VStack {}
        .sheet(isPresented: $isPresented) {
            MedicalSpecialtyBottomSheet(
                selectedSpecialty: $selectedSpecialty,
                isPresented: $isPresented
            )
        }
}
