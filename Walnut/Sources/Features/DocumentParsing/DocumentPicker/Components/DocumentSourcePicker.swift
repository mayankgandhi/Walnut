//
//  DocumentSourcePicker.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem
import UniformTypeIdentifiers
import PhotosUI

struct DocumentSourcePicker: View {
    
    let patient: Patient?
    let medicalCase: MedicalCase?
    @State var store: DocumentPickerStore
    @State private var showingActionSheet = false
    
    init(
        patient: Patient?,
        medicalCase: MedicalCase?,
        store: DocumentPickerStore,
        showingActionSheet: Bool = false
    ) {
        self.patient = patient
        self.medicalCase = medicalCase
        self.store = store
        self.showingActionSheet = showingActionSheet
    }
    
    var body: some View {
        VStack(spacing: Spacing.large) {
            
            Button {
                showingActionSheet = true
            } label: {
                DocumentUploadArea(store: store)
            }
            .confirmationDialog("Select Document Source", isPresented: $showingActionSheet, titleVisibility: .visible) {
                Button("Files") {
                    store.presentDocumentPicker()
                }
                
                Button("Photo Library") {
                    store.presentPhotosPicker()
                }
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Camera") {
                        store.presentCamera()
                    }
                }
                
                Button("Cancel", role: .cancel) { }
            }
            
            if let selectedDocumentType = store.selectedDocumentType {
                switch selectedDocumentType {
                    case .prescription:
                        if let patient, let medicalCase {
                            HStack {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.3))
                                
                                Text("or")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.3))
                            }
                            
                            AddPrescriptionManuallyButton(
                                patient: patient,
                                medicalCase: medicalCase,
                                store: store
                            )
                        }
                        
                    case .biomarkerReport:
                        if let patient = patient {
                            HStack {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.3))
                                
                                Text("or")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.3))
                            }
                            AddBiomarkerReportManuallyButton(
                                patient: patient,
                                store: store
                            )
                        } else if let medicalCase = medicalCase {
                            HStack {
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.3))
                                
                                Text("or")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.secondary.opacity(0.3))
                            }
                            AddBiomarkerReportManuallyButton(
                                medicalCase: medicalCase,
                                store: store
                            )
                        } else {
                            EmptyView()
                        }
                        
                        
                    default:
                        EmptyView()
                }
            }
            
        }
        .fileImporter(
            isPresented: $store.isDocumentPickerPresented,
            allowedContentTypes: store.supportedFileTypes,
            allowsMultipleSelection: false
        ) { result in
            store.handleDocumentSelection(result)
        }
        .photosPicker(
            isPresented: $store.isPhotosPickerPresented,
            selection: $store.selectedPhotos,
            maxSelectionCount: 1,
            matching: .images
        )
        .sheet(isPresented: $store.isCameraPresented) {
            CameraPickerView(store: store)
        }
        .onChange(of: store.selectedPhotos) { _, newValue in
            store.handlePhotosSelection(newValue)
        }
    }
}

// MARK: - Supporting Views

struct DocumentUploadArea: View {
    
    @State private var store: DocumentPickerStore
    
    init(store: DocumentPickerStore) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: store.hasSelection ? "doc.fill" : "doc.badge.arrow.up.fill")
                .font(.system(size: 56))
                .foregroundColor(store.hasSelection ? .green : .blue)
            
            Text(store.hasSelection ? "Document Selected" : "Tap to select a document or image")
                .font(.headline)
            
            if store.hasSelection {
                Text(store.selectionDisplayName)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                // Show image preview if an image is selected
                if let selectedImage = store.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 100)
                        .cornerRadius(8)
                }
            } else {
                Text("Supports PDF, images from Photos, or Camera")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 200)
        .background(Color.blue.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                .foregroundColor(.blue.opacity(0.3))
        )
        .cornerRadius(16)
    }
}

struct CameraPickerView: View {
    
    @State private var store: DocumentPickerStore
    
    init(store: DocumentPickerStore) {
        self.store = store
    }
    
    var body: some View {
        ImagePickerRepresentable(
            selectedImage: Binding(
                get: { store.selectedImage },
                set: { store.handleCameraSelection($0) }
            ),
            isPresented: $store.isCameraPresented,
            sourceType: .camera
        )
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var store = DocumentPickerStore.forAllDocuments()
    
    VStack {
        DocumentSourcePicker(patient: .samplePatient, medicalCase: .sampleCase,
                             store: store)
        .padding()
        
        Spacer()
    }
}
