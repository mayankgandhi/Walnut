//
//  DocumentSourcePicker.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

struct DocumentSourcePicker: View {
    
    @Environment(DocumentPickerStore.self) private var store
    @State private var showingActionSheet = false
    
    var body: some View {
        @Bindable var bindableStore = store
        
        Button {
            showingActionSheet = true
        } label: {
            DocumentUploadArea()
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
        .fileImporter(
            isPresented: $bindableStore.isDocumentPickerPresented,
            allowedContentTypes: store.supportedFileTypes,
            allowsMultipleSelection: false
        ) { result in
            store.handleDocumentSelection(result)
        }
        .photosPicker(
            isPresented: $bindableStore.isPhotosPickerPresented,
            selection: $bindableStore.selectedPhotos,
            maxSelectionCount: 1,
            matching: .images
        )
        .sheet(isPresented: $bindableStore.isCameraPresented) {
            CameraPickerView()
        }
        .onChange(of: store.selectedPhotos) { _, newValue in
            store.handlePhotosSelection(newValue)
        }
    }
}

// MARK: - Supporting Views

private struct DocumentUploadArea: View {
    
    @Environment(DocumentPickerStore.self) private var store
    
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

private struct CameraPickerView: View {
    
    @Environment(DocumentPickerStore.self) private var store
    
    var body: some View {
        @Bindable var bindableStore = store
        
        ImagePickerRepresentable(
            selectedImage: Binding(
                get: { store.selectedImage },
                set: { store.handleCameraSelection($0) }
            ),
            isPresented: $bindableStore.isCameraPresented,
            sourceType: .camera
        )
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var store = DocumentPickerStore.forPrescriptions()
    
    VStack {
        DocumentSourcePicker()
            .environment(store)
            .padding()
        
        Spacer()
    }
}
