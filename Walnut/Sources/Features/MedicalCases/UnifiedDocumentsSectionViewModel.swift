//
//  UnifiedDocumentsSectionViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class UnifiedDocumentsSectionViewModel {
    
    // MARK: - Published Properties
    var isLoading = false
    var error: Error?
    var showAddDocument = false
    var navigationState = NavigationState()
    
    // MARK: - Cached Properties
    private var _allDocuments: [DocumentItem] = []
    private var _lastMedicalCaseUpdate: Date?
    private var _cachedTotalCount: Int = 0
    private var _cachedUnparsedCount: Int = 0
    
    // MARK: - Private Properties
    private let factory = DocumentFactory.shared
    private var debounceTask: Task<Void, Never>?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // MARK: - Computed Properties
    
    var allDocuments: [DocumentItem] {
        return _allDocuments
    }
    
    var totalDocumentCount: Int {
        return _cachedTotalCount
    }
    
    var unparsedCount: Int {
        return _cachedUnparsedCount
    }
    
    var isEmpty: Bool {
        return _allDocuments.isEmpty
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func loadDocuments(from medicalCase: MedicalCase) {
        // Check if we need to refresh based on medical case updates
        let needsRefresh = shouldRefreshDocuments(for: medicalCase)
        
        guard needsRefresh else { return }
        
        // Cancel any pending debounce task
        debounceTask?.cancel()
        
        // Debounce rapid calls to prevent UI lag
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(50))
            
            guard !Task.isCancelled else { return }
            
            await self?.performDocumentLoad(from: medicalCase)
        }
    }
    
    @MainActor
    func refresh(from medicalCase: MedicalCase) async {
        isLoading = true
        await performDocumentLoad(from: medicalCase)
        isLoading = false
    }
    
    // MARK: - Document Formatting Methods
    
    func formatPrescriptionTitle(_ prescription: Prescription) -> String {
        if let dateIssued = prescription.dateIssued {
            return "Prescription - \(dateFormatter.string(from: dateIssued))"
        } else {
            return "Prescription"
        }
    }
    
    func formatPrescriptionSubtitle(_ prescription: Prescription) -> String {
        var components: [String] = []
        
        if let doctorName = prescription.doctorName {
            components.append(doctorName)
        }
        
        if let facilityName = prescription.facilityName {
            components.append(facilityName)
        }
        
        if prescription.followUpDate != nil {
            components.append("Follow-up required")
        }
        
        return components.isEmpty ? "Prescription document" : components.joined(separator: " • ")
    }
    
    func formatBloodReportTitle(_ bloodReport: BloodReport) -> String {
        return bloodReport.testName ?? "Blood Report"
    }
    
    func formatBloodReportSubtitle(_ bloodReport: BloodReport) -> String {
        var components: [String?] = []
        
        if let resultDate = bloodReport.resultDate {
            components.append(dateFormatter.string(from: resultDate))
        }
        
        components.append(bloodReport.labName)
        
        let abnormalCount = bloodReport.testResults.filter({ $0.isAbnormal  ?? false }).count
        if abnormalCount > 0 {
            components.append("\(abnormalCount) abnormal results")
        } else if !bloodReport.testResults.isEmpty {
            components.append("\(bloodReport.testResults.count) results")
        }
        
        return components.compactMap({ $0 }).joined(separator: " • ")
    }
    
    func formatUnparsedDocumentTitle(_ document: Document) -> String {
        return document.fileName ?? "Unparsed Document"
    }
    
    func formatUnparsedDocumentSubtitle(_ document: Document) -> String {
        var components: [String?] = []
        
        components.append( document.uploadDate == nil ? nil : dateFormatter.string(from: document.uploadDate!))
        
        if let fileSize = document.fileSize {
            let fileSize = ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
            components.append(fileSize)
        }
        
        
        components.append("Parsing failed")
        
        return components.compactMap({ $0 }).joined(separator: " • ")
    }
    
    // MARK: - Navigation Methods
    
    func selectPrescription(_ prescription: Prescription) {
        navigationState.selectedPrescription = prescription
    }
    
    func selectBloodReport(_ bloodReport: BloodReport) {
        navigationState.selectedBloodReport = bloodReport
    }
    
    func selectDocument(_ document: Document) {
        navigationState.selectedDocument = document
    }
    
    func showAddDocumentSheet() {
        showAddDocument = true
    }
    
    // MARK: - Private Methods
    
    private func shouldRefreshDocuments(for medicalCase: MedicalCase) -> Bool {
        // Check if this is the first load
        guard let lastUpdate = _lastMedicalCaseUpdate else {
            return true
        }
        
        // Check if medical case has been updated since our last cache
        let medicalCaseUpdated = medicalCase.updatedAt ?? Date.distantPast
        return medicalCaseUpdated > lastUpdate
    }
    
    @MainActor
    private func performDocumentLoad(from medicalCase: MedicalCase) async {
        do {
            // Perform expensive operations off the main thread
            let documents = await withTaskGroup(of: [DocumentItem].self, returning: [DocumentItem].self) { group in
                
                // Load prescriptions
                group.addTask {
                    return medicalCase.prescriptions.map { DocumentItem.prescription($0) }
                }
                
                // Load blood reports
                group.addTask {
                    return medicalCase.bloodReports.map { DocumentItem.bloodReport($0) }
                }
                
                // Load unparsed documents
                group.addTask {
                    return medicalCase.unparsedDocuments.map { DocumentItem.unparsedDocument($0) }
                }
                
                // Load other documents
                group.addTask {
                    return medicalCase.otherDocuments.map { DocumentItem.document($0) }
                }
                
                var allItems: [DocumentItem] = []
                for await items in group {
                    allItems.append(contentsOf: items)
                }
                
                // Sort by date (most recent first) - this is expensive, so do it once
                return allItems.sorted { item1, item2 in
                    item1.sortDate > item2.sortDate
                }
            }
            
            // Update cache atomically on main thread
            _allDocuments = documents
            _cachedTotalCount = documents.count
            _cachedUnparsedCount = medicalCase.unparsedDocuments.count
            _lastMedicalCaseUpdate = medicalCase.updatedAt ?? Date()
            
        } catch {
            self.error = error
            print("Error loading documents: \(error)")
        }
    }
    
    // MARK: - Factory Methods
    
    func createActionHandler(for item: DocumentItem) -> DocumentActionHandler {
        return factory.createActionHandler(for: item)
    }
    
    deinit {
        debounceTask?.cancel()
    }
}

// MARK: - Performance Extensions

extension UnifiedDocumentsSectionViewModel {
    
    /// Preload document metadata for better performance
    @MainActor
    func preloadDocumentMetadata(from medicalCase: MedicalCase) async {
        // This could be used to preload expensive operations like file size calculations
        // or thumbnail generation in the background
        await Task.detached(priority: .background) {
            // Preload any expensive metadata here
        }.value
    }
    
    /// Clear cache to free memory
    func clearCache() {
        _allDocuments.removeAll()
        _cachedTotalCount = 0
        _cachedUnparsedCount = 0
        _lastMedicalCaseUpdate = nil
    }
}
