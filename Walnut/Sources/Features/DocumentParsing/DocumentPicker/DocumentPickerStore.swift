//
//  DocumentPickerStore.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers
import PhotosUI

@Observable
class DocumentPickerStore {
    
    // MARK: - Published State
    var selectedDocumentType: DocumentType?
    var selectedDocument: URL?
    var selectedImage: UIImage?
    var selectedPhotos: [PhotosPickerItem] = []
    var errorMessage: String?
    var isProcessing = false
    
    // Picker presentation states
    var isDocumentPickerPresented = false
    var isPhotosPickerPresented = false  
    var isCameraPresented = false
    
    // MARK: - Configuration
    let availableDocumentTypes: [DocumentType]
    let supportedFileTypes: [UTType]
    let maxFileSizeMB: Int
    
    // MARK: - Computed Properties
    var hasSelection: Bool {
        selectedDocument != nil || selectedImage != nil
    }
    
    var selectionDisplayName: String {
        if let document = selectedDocument {
            return document.lastPathComponent
        } else if selectedImage != nil {
            return "Selected Image"
        }
        return ""
    }
    
    var canUpload: Bool {
        hasSelection && !isProcessing
    }

    // MARK: - Initialization
    
    init(
        documentTypes: [DocumentType] = DocumentType.allCases,
        supportedFileTypes: [UTType] = [.pdf, .jpeg, .png],
        maxFileSizeMB: Int = 50,
    ) {
        self.availableDocumentTypes = documentTypes
        self.supportedFileTypes = supportedFileTypes
        self.maxFileSizeMB = maxFileSizeMB
        self.selectedDocumentType = nil
    }
    
    // MARK: - Public Actions
    
    func clearSelection() {
        selectedDocument = nil
        selectedImage = nil
        selectedPhotos.removeAll()
        errorMessage = nil
    }
    
    func resetState() {
        selectedDocumentType = nil
        clearSelection()
    }
    
    func selectDocumentType(_ type: DocumentType) {
        selectedDocumentType = type
    }
    
    func presentDocumentPicker() {
        isDocumentPickerPresented = true
    }
    
    func presentPhotosPicker() {
        isPhotosPickerPresented = true
    }
    
    func presentCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            errorMessage = "Camera not available on this device"
            return
        }
        isCameraPresented = true
    }
    
    // MARK: - Document Handling
    
    func handleDocumentSelection(_ result: Result<[URL], Error>) {
        clearSelection()
        
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            // Store the selected document URL directly
            // File saving will be handled by the DocumentProcessingUseCase
            selectedDocument = url
            errorMessage = nil
            
        case .failure(let error):
            errorMessage = "Failed to select document: \(error.localizedDescription)"
        }
    }
    
    func handlePhotosSelection(_ photos: [PhotosPickerItem]) {
        guard let photo = photos.first else { return }
        
        // Clear existing selections
        clearSelection()
        
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
    
    func handleCameraSelection(_ image: UIImage?) {
        if let image = image {
            // Clear existing selections
            clearSelection()
            
            selectedImage = image
            errorMessage = nil
        }
    }
    
    // MARK: - Validation
    
    func validateSelection() -> Bool {
        guard hasSelection else {
            errorMessage = "Please select a document or image"
            return false
        }
        
        errorMessage = nil
        return true
    }
    
    // MARK: - Cleanup
    
    deinit {
        selectedDocument?.stopAccessingSecurityScopedResource()
    }
}

// MARK: - Factory Methods

extension DocumentPickerStore {
    static func forAllDocuments() -> DocumentPickerStore {
        DocumentPickerStore(
            documentTypes: DocumentType.allCases
        )
    }
}
