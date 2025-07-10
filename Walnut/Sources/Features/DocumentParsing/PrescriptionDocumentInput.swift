//
//  Document.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

struct PrescriptionDocumentInput: Identifiable, Hashable, Codable {
    var id: UUID
    var fileName: String
    var documentDate: Date
    var summary: String
    var fileSize: Int64
    
    init(id: UUID, fileName: String, documentDate: Date, summary: String, fileSize: Int64) {
        self.id = id
        self.fileName = fileName
        self.documentDate = documentDate
        self.summary = summary
        self.fileSize = fileSize
    }
}
