//
//  Document.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData

@Model
class Document: Identifiable, Hashable {
    
    @Attribute(.unique)
    var id: UUID
    
    var fileName: String
    var fileURL: URL
    
    var documentType: DocumentType
    var uploadDate: Date
    
    var fileSize: Int64
    
    var createdAt: Date
    var updatedAt: Date
        
    init(
        id: UUID = UUID(),
        fileName: String,
        fileURL: URL,
        documentType: DocumentType,
        uploadDate: Date = Date(),
        fileSize: Int64,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.fileName = fileName
        self.fileURL = fileURL
        self.documentType = documentType
        self.uploadDate = uploadDate
        self.fileSize = fileSize
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Document {
    
    @MainActor
    static var document: Document =  Document(
        id: UUID(),
        fileName: "Blood_Test_Results_2024.pdf",
        fileURL: URL(string: "file://")!,
        documentType: .labResult,
        uploadDate: Date().addingTimeInterval(-86400 * 2),
        fileSize: 245760
    )
    
    @MainActor
    static var sampleDocuments: [Document] = [
        
        Document(
            id: UUID(),
            fileName: "Prescription_Cardiology.pdf",
            fileURL: URL(string: "file://")!,
            documentType: .prescription,
            uploadDate: Date().addingTimeInterval(-86400 * 1),
            fileSize: 123456
        ),
        Document(
            id: UUID(),
            fileName: "Chest_XRay_Report.jpg",
            fileURL: URL(string: "file://")!,
            documentType: .labResult,
            uploadDate: Date().addingTimeInterval(-86400 * 10),
            fileSize: 2097152
        )
    ]
}
