//
//  DocumentData.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//


import UniformTypeIdentifiers

// Document Data Model
struct DocumentData: Identifiable {
    let id: UUID
    let fileName: String
    let fileURL: URL
    let documentType: String
    let documentDate: Date
    let uploadDate: Date
    let fileSize: Int64
    var extractionError: String?
}