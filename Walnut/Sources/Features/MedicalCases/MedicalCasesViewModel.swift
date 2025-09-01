//
//  MedicalCasesViewModel.swift
//  Walnut
//
//  Created by Mayank Gandhi on 29/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import Observation

@Observable
class MedicalCasesViewModel {
    
    // MARK: - Published Properties
    var medicalCases: [MedicalCase] = []
    var searchText = ""
    var isLoading = false
    var error: Error?
    
    // Navigation and Sheet States
    var selectedCase: MedicalCase?
    var showCreateView = false
    var caseToEdit: MedicalCase?
    var showDeleteAlert = false
    var caseToDelete: MedicalCase?
    
    // MARK: - Private Properties
    let patient: Patient
    private let modelContext: ModelContext
    private var debounceTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    var filteredAndSortedCases: [MedicalCase] {
        var cases = medicalCases
        
        // Apply search filter
        if !searchText.isEmpty {
            cases = cases.filter { medicalCase in
                medicalCase.title?
                    .localizedCaseInsensitiveContains(searchText) ?? false ||
                medicalCase.notes?
                    .localizedCaseInsensitiveContains(searchText) ?? false ||
                medicalCase.patient?.name?
                    .localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        return cases
    }
    
    var isEmpty: Bool {
        return medicalCases.isEmpty
    }
    
    var hasFilteredResults: Bool {
        return !filteredAndSortedCases.isEmpty
    }
    
    // MARK: - Initializer
    
    init(patient: Patient, modelContext: ModelContext) {
        self.patient = patient
        self.modelContext = modelContext
    }
    
    // MARK: - Data Fetching
    
    @MainActor
    func fetchMedicalCases(patientID: UUID) async {
        isLoading = true
        error = nil
        
        do {
            let descriptor = FetchDescriptor<MedicalCase>(
                predicate: #Predicate<MedicalCase> { medicalCase in
                    if let patient = medicalCase.patient,
                       let id = patient.id {
                        return id == patientID
                    } else {
                        return false
                    }
                },
                sortBy: [SortDescriptor(\MedicalCase.updatedAt, order: .reverse)]
            )
            medicalCases = try modelContext.fetch(descriptor)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refreshData() {
        Task {
            if let patientID = patient.id {
                await fetchMedicalCases(patientID: patientID)
            }
        }
    }
    
    // MARK: - Search Management
    
    func updateSearchText(_ newText: String) {
        // Cancel any existing debounce task
        debounceTask?.cancel()
        
        // Debounce search updates to prevent excessive filtering
        debounceTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self?.searchText = newText
            }
        }
    }
    
    func clearSearch() {
        searchText = ""
        debounceTask?.cancel()
    }
    
    // MARK: - Navigation Actions
    
    func selectCase(_ medicalCase: MedicalCase) {
        selectedCase = medicalCase
    }
    
    func showCreateMedicalCase() {
        showCreateView = true
    }
    
    func editCase(_ medicalCase: MedicalCase) {
        caseToEdit = medicalCase
    }
    
    func confirmDeleteCase(_ medicalCase: MedicalCase) {
        caseToDelete = medicalCase
        showDeleteAlert = true
    }
    
    // MARK: - CRUD Operations
    
    @MainActor
    func deleteCase() async {
        guard let caseToDelete = caseToDelete else { return }
        
        do {
            modelContext.delete(caseToDelete)
            try modelContext.save()
            
            // Remove from local array immediately for better UX
            medicalCases.removeAll { $0.id == caseToDelete.id }
            
            // Clear delete state
            self.caseToDelete = nil
            showDeleteAlert = false
            
        } catch {
            self.error = error
        }
    }
    
    func cancelDelete() {
        caseToDelete = nil
        showDeleteAlert = false
    }
    
    // MARK: - Sheet Management
    
    func dismissCreateSheet() {
        showCreateView = false
        // Refresh data after potential creation
        refreshData()
    }
    
    func dismissEditSheet() {
        caseToEdit = nil
        // Refresh data after potential edit
        refreshData()
    }
    
    // MARK: - Cleanup
    
    deinit {
        debounceTask?.cancel()
    }
}

// MARK: - Extensions

extension MedicalCasesViewModel {
    
    /// Check if a medical case matches search criteria
    private func matchesSearch(_ medicalCase: MedicalCase, searchTerm: String) -> Bool {
        let searchTerm = searchTerm.lowercased()
        
        // Search in title
        if let title = medicalCase.title?.lowercased(),
           title.contains(searchTerm) {
            return true
        }
        
        // Search in notes
        if let notes = medicalCase.notes?.lowercased(),
           notes.contains(searchTerm) {
            return true
        }
        
        // Search in patient name
        if let patientName = medicalCase.patient?.name?.lowercased(),
           patientName.contains(searchTerm) {
            return true
        }
        
        // Search in specialty or type (if needed)
        if let specialty = medicalCase.specialty?.rawValue.lowercased(),
           specialty.contains(searchTerm) {
            return true
        }
        
        return false
    }
    
    /// Get context menu actions for a medical case
    func getContextMenuActions(for medicalCase: MedicalCase) -> [(String, String, () -> Void)] {
        return [
            ("View Details", "doc.text", { [weak self] in
                self?.selectCase(medicalCase)
            }),
            ("Edit", "pencil", { [weak self] in
                self?.editCase(medicalCase)
            }),
            ("Delete", "trash", { [weak self] in
                self?.confirmDeleteCase(medicalCase)
            })
        ]
    }
}
