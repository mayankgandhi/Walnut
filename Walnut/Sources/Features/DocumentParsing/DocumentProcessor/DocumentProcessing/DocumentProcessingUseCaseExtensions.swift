//
//  DocumentProcessingUseCaseExtensions.swift
//  Walnut
//
//  Created by Mayank Gandhi on 01/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import SwiftUI
import AIKit

// MARK: - DocumentProcessingUseCase Convenience Extensions

extension DocumentProcessingUseCase {
    
    /// Convenience method for processing a document file URL
    func execute(
        documentURL: URL,
        for medicalCase: MedicalCase,
        documentType: DocumentType
    ) async throws -> ProcessingResult {
        
        let input = DocumentProcessingInput(
            fileSource: .documentURL(documentURL),
            medicalCase: medicalCase,
            documentType: documentType
        )
        
        return try await execute(input: input)
    }
    
    /// Convenience method for processing an image
    func execute(
        image: UIImage,
        for medicalCase: MedicalCase,
        documentType: DocumentType
    ) async throws -> ProcessingResult {
        
        let input = DocumentProcessingInput(
            fileSource: .imageData(image),
            medicalCase: medicalCase,
            documentType: documentType
        )
        
        return try await execute(input: input)
    }

}
