//
//  AddPatientView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct AddPatientView: View {
    @Bindable var store: StoreOf<AddPatientFeature>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    personalInfoSection
                    medicalInfoSection
                    emergencyContactSection
                    notesSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color.walnutBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Check if form has been modified before dismissing
                        if hasFormData {
                            store.send(.alert(.presented(.confirmDismiss)))
                        } else {
                            store.send(.delegate(.dismiss))
                        }
                    }
                    .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.send(.savePatient)
                    }
                    .foregroundColor(store.isFormValid ? .healthBlue : .textSecondary)
                    .fontWeight(.semibold)
                    .disabled(!store.isFormValid || store.isLoading)
                }
            }
            .overlay {
                if store.isLoading {
                    LoadingOverlay()
                }
            }
            .alert(store: store.scope(state: \.$alert, action: \.alert))
            .sheet(isPresented: $store.isDatePickerPresented) {
                DatePickerSheet(
                    selectedDate: $store.dateOfBirth,
                    onDismiss: { store.send(.dismissDatePicker) }
                )
            }
        }
    }
    
    private var hasFormData: Bool {
        !store.firstName.isEmpty ||
        !store.lastName.isEmpty ||
        store.dateOfBirth != nil ||
        !store.gender.isEmpty ||
        !store.bloodType.isEmpty ||
        !store.emergencyContactName.isEmpty ||
        !store.emergencyContactPhone.isEmpty ||
        !store.notes.isEmpty
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.healthBlue)
            
            Text("Add New Patient")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text("Enter patient information to create a new profile")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }
    
    private var personalInfoSection: some View {
        FormSection(title: "Personal Information", icon: "person.circle") {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    WalnutTextField(
                        title: "First Name",
                        text: $store.firstName,
                        placeholder: "Enter first name"
                    )
                    
                    WalnutTextField(
                        title: "Last Name",
                        text: $store.lastName,
                        placeholder: "Enter last name"
                    )
                }
                
                DateOfBirthField(
                    selectedDate: store.dateOfBirth,
                    onTap: { store.send(.dateOfBirthTapped) }
                )
                
                PickerField(
                    title: "Gender",
                    selection: $store.gender,
                    options: store.genderOptions,
                    placeholder: "Select gender"
                )
            }
        }
    }
    
    private var medicalInfoSection: some View {
        FormSection(title: "Medical Information", icon: "cross.circle") {
            VStack(spacing: 16) {
                PickerField(
                    title: "Blood Type",
                    selection: $store.bloodType,
                    options: store.bloodTypeOptions,
                    placeholder: "Select blood type"
                )
            }
        }
    }
    
    private var emergencyContactSection: some View {
        FormSection(title: "Emergency Contact", icon: "phone.circle") {
            VStack(spacing: 16) {
                WalnutTextField(
                    title: "Contact Name",
                    text: $store.emergencyContactName,
                    placeholder: "Enter contact name"
                )
                
                WalnutTextField(
                    title: "Phone Number",
                    text: $store.emergencyContactPhone,
                    placeholder: "Enter phone number",
                    keyboardType: .phonePad
                )
            }
        }
    }
    
    private var notesSection: some View {
        FormSection(title: "Additional Notes", icon: "note.text") {
            WalnutTextEditor(
                text: $store.notes,
                placeholder: "Enter any additional notes or medical history..."
            )
        }
    }
}

// MARK: - Supporting Views
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .healthBlue))
                    .scaleEffect(1.5)
                
                Text("Saving Patient...")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .shadowColor.opacity(0.2), radius: 10, x: 0, y: 4)
        }
    }
}

// MARK: - Preview

#Preview {
    AddPatientView(
        store: Store(initialState: AddPatientFeature.State()) {
            AddPatientFeature()
        }
    )
}
