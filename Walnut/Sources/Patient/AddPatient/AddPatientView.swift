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
            Form {
                headerSection
                personalInfoSection
                medicalInfoSection
                emergencyContactSection
                notesSection
            }
            .navigationTitle("New Patient")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if hasFormData {
                            store.send(.showDismissAlertFormFilled)
                        } else {
                            store.send(.delegate(.dismissAddFlow))
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        store.send(.savePatient)
                    }
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
        Section {
            VStack(spacing: 12) {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 56))
                    .foregroundColor(.accentColor)
                    .frame(maxWidth: .infinity)
                
                Text("Enter patient information to create a new profile")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 20)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }
    
    private var personalInfoSection: some View {
        Section("Personal Information") {
            HStack {
                TextField("First Name", text: $store.firstName)
                Divider()
                TextField("Last Name", text: $store.lastName)
            }
            
            Button(action: { store.send(.dateOfBirthTapped) }) {
                HStack {
                    Text("Date of Birth")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(store.dateOfBirth.map {
                        DateFormatter.localizedString(from: $0, dateStyle: .medium, timeStyle: .none)
                    } ?? "Select")
                    .foregroundColor(store.dateOfBirth != nil ? .primary : .secondary)
                }
            }
            
            Picker("Gender", selection: $store.gender) {
                Text("Select Gender").tag("")
                ForEach(store.genderOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        }
    }
    
    private var medicalInfoSection: some View {
        Section("Medical Information") {
            Picker("Blood Type", selection: $store.bloodType) {
                Text("Select Blood Type").tag("")
                ForEach(store.bloodTypeOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
        }
    }
    
    private var emergencyContactSection: some View {
        Section("Emergency Contact") {
            TextField("Contact Name", text: $store.emergencyContactName)
            
            TextField("Phone Number", text: $store.emergencyContactPhone)
                .keyboardType(.phonePad)
        }
    }
    
    private var notesSection: some View {
        Section("Additional Notes") {
            ZStack(alignment: .topLeading) {
                if store.notes.isEmpty {
                    Text("Enter any additional notes or medical history...")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 5)
                }
                
                TextEditor(text: $store.notes)
                    .frame(minHeight: 100)
                    .padding(.horizontal, -5)
            }
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
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                
                Text("Saving Patient...")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            )
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
