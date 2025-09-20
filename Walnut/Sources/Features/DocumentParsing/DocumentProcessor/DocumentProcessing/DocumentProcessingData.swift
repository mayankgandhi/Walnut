//
//  DocumentProcessingData.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftData

// MARK: - Document Processing Input

/// Contains all the data needed to process a document
struct DocumentProcessingInput {
    let fileSource: FileInputSource
    let medicalCase: MedicalCase?
    let patient: Patient?
    let documentType: DocumentType
    let processingDate: Date

    init(
        fileSource: FileInputSource,
        medicalCase: MedicalCase? = nil,
        patient: Patient? = nil,
        documentType: DocumentType,
        processingDate: Date = Date()
    ) {
        self.fileSource = fileSource
        self.medicalCase = medicalCase
        self.patient = patient
        self.documentType = documentType
        self.processingDate = processingDate
    }
}

// MARK: - Processing Stage Data

/// Data passed between processing stages
struct DocumentProcessingStageData {
    let preparedFile: PreparedFileInput
    let medicalCase: MedicalCase?
    let patient: Patient?
    let documentType: DocumentType
}

// MARK: - Factory Methods

extension DocumentProcessingInput {
    
    /// Creates input from DocumentPickerStore (for compatibility)
    static func from(
        store: DocumentPickerStore,
        medicalCase: MedicalCase?,
        patient: Patient,
        documentType: DocumentType
    ) throws -> DocumentProcessingInput {
        
        let fileSource: FileInputSource
        
        if let selectedDocument = store.selectedDocument {
            fileSource = .documentURL(selectedDocument)
        } else if let selectedImage = store.selectedImage {
            fileSource = .imageData(selectedImage)
        } else {
            throw DocumentProcessingError.filePreparationFailed(
                NSError(
                    domain: "DocumentProcessingInput",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: "No file selected in store"]
                )
            )
        }
        
        return DocumentProcessingInput(
            fileSource: fileSource,
            medicalCase: medicalCase,
            patient: patient,
            documentType: documentType
        )
    }
}
