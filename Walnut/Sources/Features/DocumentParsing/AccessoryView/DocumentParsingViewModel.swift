//
//  DocumentParsingViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import Combine

class DocumentParsingViewModel: ObservableObject {
    
    @Environment(\.modelContext) var modelContext
    
    @Published var showAccessory: Bool = false
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var parsedDocument: ParsedPrescription?
    
    enum DocumentParsingState {
        case idle
        case processing
        case success
    }
    
    private let claudeService: ClaudeDocumentService
    private var cancellables = Set<AnyCancellable>()

    init(
        apiKey: String
    ) {
        self.claudeService = ClaudeDocumentService(apiKey: apiKey)
        
        DocumentParsingViewCoordinator.shared.fileUploadSubject
            .sink { [weak self] medicalCase, file in
                Task {
                    print("Hitting the sink of file upload subject")
                    if let parsedPrescription = await self?.parsePrescription(fileURL: file) {
                        let prescription = Prescription(
                            parsedPrescription: parsedPrescription,
                            medicalCase: medicalCase,
                            fileURL: file
                        )
                        medicalCase.prescriptions.append(prescription)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func parsePrescription(fileURL: URL) async -> ParsedPrescription? {
        await self.toggleView()
        
        await MainActor.run {
            isProcessing = true
            errorMessage = nil
        }
        
        do {
            let parsedDocument = try await claudeService.uploadAndParseDocument(from: fileURL, as: ParsedPrescription.self)
            dump(parsedDocument)
            await MainActor.run {
                self.parsedDocument = parsedDocument
                self.isProcessing = false
                fileURL.stopAccessingSecurityScopedResource()
                toggleView(delay: 2)
            }
            
            return parsedDocument
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isProcessing = false
                fileURL.stopAccessingSecurityScopedResource()
                toggleView(delay: 2)
            }
            return nil
        }
    }
    
    func toggleView(delay: Double = 0) {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            self.showAccessory = !showAccessory
        }
    }
}
