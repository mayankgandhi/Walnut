//
//  DocumentPickerView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers
import PhotosUI

// Document Picker View
struct DocumentPickerView: View {
    
    init(medicalCase: MedicalCase) {
        self.medicalCase = medicalCase
    }
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDocumentType: DocumentType = .billing
    @State private var isDocumentPickerPresented = false
    @State private var isPhotosPickerPresented = false
    @State private var isCameraPresented = false
    @State private var selectedDocument: URL?
    @State private var selectedImage: UIImage?
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var errorMessage: String?
    @State private var showingSourceActionSheet = false

    let documentTypes = [DocumentType.prescription]
    let medicalCase: MedicalCase
    
    // Supported file types for documents
    private let supportedTypes: [UTType] = [
        .pdf,
        .jpeg,
        .png,
        .heic
    ]
    
    private var hasSelection: Bool {
        selectedDocument != nil || selectedImage != nil
    }
    
    private var selectionDisplayName: String {
        if let document = selectedDocument {
            return document.lastPathComponent
        } else if selectedImage != nil {
            return "Selected Image"
        }
        return ""
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Document Type Selector
                VStack(alignment: .leading, spacing: 12) {
                    Text("Document Type")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(documentTypes, id: \.self) { type in
                                DocumentTypeButton(
                                    type: type,
                                    isSelected: selectedDocumentType == type
                                ) {
                                    selectedDocumentType = type
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Menu {
                    Button("Files", action: {
                        isDocumentPickerPresented = true
                    })
                    Button("Photo Library", action: {
                        isPhotosPickerPresented = true
                    })
                    Button("PhotoPicker", action: {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            isCameraPresented = true
                        } else {
                            errorMessage = "Camera not available"
                        }
                    })
                } label: {
                    // Upload Area
                    VStack(spacing: 16) {
                        Image(systemName: hasSelection ? "doc.fill.badge.checkmark" : "doc.badge.arrow.up.fill")
                            .font(.system(size: 56))
                            .foregroundColor(hasSelection ? .green : .blue)
                        
                        Text(hasSelection ? "Document Selected" : "Tap to select a document or image")
                            .font(.headline)
                        
                        if hasSelection {
                            Text(selectionDisplayName)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            // Show image preview if an image is selected
                            if let selectedImage = selectedImage {
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
                    .padding(.horizontal)
                }
                
                // Clear selection button
                if hasSelection {
                    Button(action: clearSelection) {
                        Text("Clear Selection")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding(.horizontal)
                }
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                // Upload button (if document or image is selected)
                if hasSelection {
                    Button(action: uploadContent) {
                        Text("Upload \(selectedDocument != nil ? "Document" : "Image")")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Add Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $isDocumentPickerPresented,
                allowedContentTypes: supportedTypes,
                allowsMultipleSelection: false
            ) { result in
                handleDocumentSelection(result)
            }
            .photosPicker(
                isPresented: $isPhotosPickerPresented,
                selection: $selectedPhotos,
                maxSelectionCount: 1,
                matching: .images
            )
            .sheet(isPresented: $isCameraPresented) {
                ImagePickerRepresentable(
                    selectedImage: $selectedImage,
                    isPresented: $isCameraPresented,
                    sourceType: .camera
                )
            }
            .onChange(of: selectedPhotos) { newValue in
                handlePhotosSelection(newValue)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func clearSelection() {
        selectedDocument?.stopAccessingSecurityScopedResource()
        selectedDocument = nil
        selectedImage = nil
        selectedPhotos.removeAll()
        errorMessage = nil
    }
    
    private func handleDocumentSelection(_ result: Result<[URL], Error>) {
        // Clear any existing selections
        clearSelection()
        
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                errorMessage = "Unable to access the selected file"
                return
            }
            
            // Validate file size (optional - adjust as needed)
            do {
                let resources = try url.resourceValues(forKeys: [.fileSizeKey])
                if let fileSize = resources.fileSize, fileSize > 50_000_000 { // 50MB limit
                    url.stopAccessingSecurityScopedResource()
                    errorMessage = "File size exceeds 50MB limit"
                    return
                }
            } catch {
                url.stopAccessingSecurityScopedResource()
                errorMessage = "Unable to read file information"
                return
            }
            
            selectedDocument = url
            errorMessage = nil
            
        case .failure(let error):
            errorMessage = "Failed to select document: \(error.localizedDescription)"
        }
    }
    
    private func handlePhotosSelection(_ photos: [PhotosPickerItem]) {
        guard let photo = photos.first else { return }
        
        // Clear existing selections
        selectedDocument?.stopAccessingSecurityScopedResource()
        selectedDocument = nil
        
        photo.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let image = UIImage(data: data) {
                        self.selectedImage = image
                        self.errorMessage = nil
                    } else {
                        self.errorMessage = "Failed to load selected image"
                    }
                case .failure(let error):
                    self.errorMessage = "Failed to load image: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func uploadContent() {
        if let document = selectedDocument {
            uploadDocument(document)
        } else if let image = selectedImage {
            uploadImage(image)
        }
    }
    
    private func uploadDocument(_ document: URL) {
        // Implement your document upload logic here
        print("Uploading document: \(document.lastPathComponent)")
        print("Document type: \(selectedDocumentType)")
        
        // Example: Copy file to app's documents directory
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsPath.appendingPathComponent(document.lastPathComponent)
            
            // Remove existing file if it exists
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Copy file
            try FileManager.default.copyItem(at: document, to: destinationURL)
            
            
            // Stop accessing security-scoped resource
            document.stopAccessingSecurityScopedResource()
            
            // Handle successful upload
            print("Document successfully saved to: \(destinationURL)")
            DocumentParsingViewCoordinator.shared.fileUploadSubject.send((medicalCase, destinationURL))
            dismiss()
            
        } catch {
            errorMessage = "Failed to save document: \(error.localizedDescription)"
        }
    }
    
    @MainActor
    private func uploadImage(_ image: UIImage) {
        // Implement your image upload logic here
        print("Uploading image")
        print("Document type: \(selectedDocumentType)")
        
        // Example: Save image to app's documents directory
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileName = "image_\(Date().timeIntervalSince1970).jpg"
            let destinationURL = documentsPath.appendingPathComponent(fileName)
            
            // Convert image to JPEG data
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                errorMessage = "Failed to process image"
                return
            }
            
            // Save image data
            try imageData.write(to: destinationURL)
            
            // Handle successful upload
            print("Image successfully saved to: \(destinationURL)")
            DocumentParsingViewCoordinator.shared.fileUploadSubject.send((medicalCase, destinationURL))
            dismiss()
            
        } catch {
            errorMessage = "Failed to save image: \(error.localizedDescription)"
        }
    }
}
