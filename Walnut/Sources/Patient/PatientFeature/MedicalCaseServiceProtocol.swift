//
//  MedicalCaseServiceProtocol.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import CoreData
import Foundation
import Combine
import Dependencies

// MARK: - Medical Case Service Protocol
protocol MedicalCaseServiceProtocol {
    // Medical Case Operations
    func createMedicalCase(
        patientID: UUID,
        title: String,
        notes: String?,
        treatmentPlan: String?,
        followUpRequired: Bool
    ) async throws -> MedicalCase
    
    func updateMedicalCase(
        caseID: UUID,
        title: String,
        notes: String?,
        treatmentPlan: String?,
        followUpRequired: Bool
    ) async throws -> MedicalCase
    
    func loadMedicalCases(for patientID: UUID) async throws -> [MedicalCase]
    func deleteMedicalCase(_ medicalCase: MedicalCase) async throws
    func getMedicalCase(by id: UUID) async throws -> MedicalCase?
    
    // Related Data Operations
    func loadMedicalRecords(for caseID: UUID) async throws -> [MedicalRecord]
    func loadLabResults(for caseID: UUID) async throws -> [LabResult]
    func loadDocuments(for caseID: UUID) async throws -> [Document]
    func loadCalendarEvents(for caseID: UUID) async throws -> [CalendarEvent]
    
    // Medical Record Operations
    func createMedicalRecord(
        caseID: UUID,
        patientID: UUID,
        title: String,
        recordType: String?,
        summary: String?,
        notes: String?,
        providerName: String?,
        dateRecorded: Date?
    ) async throws -> MedicalRecord
    
    // Lab Result Operations
    func createLabResult(
        caseID: UUID,
        patientID: UUID,
        testName: String,
        labName: String?,
        category: String?,
        status: String?,
        resultDate: Date?
    ) async throws -> LabResult
    
    // Document Operations
    func createDocument(
        caseID: UUID,
        patientID: UUID,
        fileName: String,
        documentType: String?,
        fileURL: URL?,
        fileSize: Int64,
        documentDate: Date?
    ) async throws -> Document
    
    // Calendar Event Operations
    func createCalendarEvent(
        caseID: UUID,
        patientID: UUID,
        title: String,
        startDate: Date,
        location: String?,
        notes: String?,
        eventType: String?
    ) async throws -> CalendarEvent
}

// MARK: - Medical Case Errors
enum MedicalCaseError: LocalizedError {
    case invalidData(String)
    case patientNotFound
    case caseNotFound
    case recordNotFound
    case databaseError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidData(let message):
            return message
        case .patientNotFound:
            return "Patient not found"
        case .caseNotFound:
            return "Medical case not found"
        case .recordNotFound:
            return "Record not found"
        case .databaseError:
            return "Database operation failed"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Medical Case Service Implementation
class MedicalCaseService: MedicalCaseServiceProtocol, ObservableObject {
    
    static let shared = MedicalCaseService()
    
    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()
    
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    private init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        
        // Listen for context changes
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Medical Case Operations
    
    func createMedicalCase(
        patientID: UUID,
        title: String,
        notes: String? = nil,
        treatmentPlan: String? = nil,
        followUpRequired: Bool = false
    ) async throws -> MedicalCase {
        
        return try await performBackgroundTask { context in
            // Validate input
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedTitle.isEmpty else {
                throw MedicalCaseError.invalidData("Case title cannot be empty")
            }
            
            // Find patient
            let patientFetch = NSFetchRequest<Patient>(entityName: "Patient")
            patientFetch.predicate = NSPredicate(format: "id == %@", patientID as CVarArg)
            patientFetch.fetchLimit = 1
            
            guard let patient = try context.fetch(patientFetch).first else {
                throw MedicalCaseError.patientNotFound
            }
            
            // Create medical case
            let medicalCase = MedicalCase(context: context)
            medicalCase.id = UUID()
            medicalCase.title = trimmedTitle
            medicalCase.notes = notes?.isEmpty == false ? notes : nil
            medicalCase.treatmentPlan = treatmentPlan?.isEmpty == false ? treatmentPlan : nil
            medicalCase.followUpRequired = followUpRequired
            medicalCase.createdAt = Date()
            medicalCase.updatedAt = Date()
            medicalCase.patient = patient
            
            try context.save()
            
            return medicalCase
        }
    }
    
    func updateMedicalCase(
        caseID: UUID,
        title: String,
        notes: String? = nil,
        treatmentPlan: String? = nil,
        followUpRequired: Bool = false
    ) async throws -> MedicalCase {
        
        return try await performBackgroundTask { context in
            // Validate input
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedTitle.isEmpty else {
                throw MedicalCaseError.invalidData("Case title cannot be empty")
            }
            
            // Find medical case
            let caseFetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            caseFetch.predicate = NSPredicate(format: "id == %@", caseID as CVarArg)
            caseFetch.fetchLimit = 1
            
            guard let medicalCase = try context.fetch(caseFetch).first else {
                throw MedicalCaseError.caseNotFound
            }
            
            // Update medical case
            medicalCase.title = trimmedTitle
            medicalCase.notes = notes?.isEmpty == false ? notes : nil
            medicalCase.treatmentPlan = treatmentPlan?.isEmpty == false ? treatmentPlan : nil
            medicalCase.followUpRequired = followUpRequired
            medicalCase.updatedAt = Date()
            
            try context.save()
            
            return medicalCase
        }
    }
    
    func loadMedicalCases(for patientID: UUID) async throws -> [MedicalCase] {
        return try await performBackgroundTask { context in
            let fetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            fetch.predicate = NSPredicate(format: "patient.id == %@", patientID as CVarArg)
            fetch.sortDescriptors = [
                NSSortDescriptor(keyPath: \MedicalCase.createdAt, ascending: false)
            ]
            
            return try context.fetch(fetch)
        }
    }
    
    func deleteMedicalCase(_ medicalCase: MedicalCase) async throws {
        try await performBackgroundTask { context in
            // Find the case in the background context
            guard let caseID = medicalCase.id else {
                throw MedicalCaseError.invalidData("Medical case ID is missing")
            }
            
            let fetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            fetch.predicate = NSPredicate(format: "id == %@", caseID as CVarArg)
            fetch.fetchLimit = 1
            
            guard let caseToDelete = try context.fetch(fetch).first else {
                throw MedicalCaseError.caseNotFound
            }
            
            context.delete(caseToDelete)
            try context.save()
        }
    }
    
    func getMedicalCase(by id: UUID) async throws -> MedicalCase? {
        return try await performBackgroundTask { context in
            let fetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            fetch.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            fetch.fetchLimit = 1
            
            return try context.fetch(fetch).first
        }
    }
    
    // MARK: - Related Data Operations
    
    func loadMedicalRecords(for caseID: UUID) async throws -> [MedicalRecord] {
        return try await performBackgroundTask { context in
            let fetch = NSFetchRequest<MedicalRecord>(entityName: "MedicalRecord")
            fetch.predicate = NSPredicate(format: "medicalCase.id == %@", caseID as CVarArg)
            fetch.sortDescriptors = [
                NSSortDescriptor(keyPath: \MedicalRecord.dateRecorded, ascending: false),
                NSSortDescriptor(keyPath: \MedicalRecord.createdAt, ascending: false)
            ]
            
            return try context.fetch(fetch)
        }
    }
    
    func loadLabResults(for caseID: UUID) async throws -> [LabResult] {
        return try await performBackgroundTask { context in
            let fetch = NSFetchRequest<LabResult>(entityName: "LabResult")
            fetch.predicate = NSPredicate(format: "medicalCase.id == %@", caseID as CVarArg)
            fetch.sortDescriptors = [
                NSSortDescriptor(keyPath: \LabResult.resultDate, ascending: false),
                NSSortDescriptor(keyPath: \LabResult.createdAt, ascending: false)
            ]
            
            return try context.fetch(fetch)
        }
    }
    
    func loadDocuments(for caseID: UUID) async throws -> [Document] {
        return try await performBackgroundTask { context in
            let fetch = NSFetchRequest<Document>(entityName: "Document")
            fetch.predicate = NSPredicate(format: "medicalCase.id == %@", caseID as CVarArg)
            fetch.sortDescriptors = [
                NSSortDescriptor(keyPath: \Document.documentDate, ascending: false),
                NSSortDescriptor(keyPath: \Document.uploadDate, ascending: false)
            ]
            
            return try context.fetch(fetch)
        }
    }
    
    func loadCalendarEvents(for caseID: UUID) async throws -> [CalendarEvent] {
        return try await performBackgroundTask { context in
            let fetch = NSFetchRequest<CalendarEvent>(entityName: "CalendarEvent")
            fetch.predicate = NSPredicate(format: "medicalCase.id == %@", caseID as CVarArg)
            fetch.sortDescriptors = [
                NSSortDescriptor(keyPath: \CalendarEvent.startDate, ascending: true)
            ]
            
            return try context.fetch(fetch)
        }
    }
    
    // MARK: - Medical Record Operations
    
    func createMedicalRecord(
        caseID: UUID,
        patientID: UUID,
        title: String,
        recordType: String? = nil,
        summary: String? = nil,
        notes: String? = nil,
        providerName: String? = nil,
        dateRecorded: Date? = nil
    ) async throws -> MedicalRecord {
        
        return try await performBackgroundTask { context in
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedTitle.isEmpty else {
                throw MedicalCaseError.invalidData("Record title cannot be empty")
            }
            
            // Find medical case and patient
            let caseFetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            caseFetch.predicate = NSPredicate(format: "id == %@", caseID as CVarArg)
            caseFetch.fetchLimit = 1
            
            let patientFetch = NSFetchRequest<Patient>(entityName: "Patient")
            patientFetch.predicate = NSPredicate(format: "id == %@", patientID as CVarArg)
            patientFetch.fetchLimit = 1
            
            guard let medicalCase = try context.fetch(caseFetch).first else {
                throw MedicalCaseError.caseNotFound
            }
            
            guard let patient = try context.fetch(patientFetch).first else {
                throw MedicalCaseError.patientNotFound
            }
            
            // Create medical record
            let record = MedicalRecord(context: context)
            record.id = UUID()
            record.title = trimmedTitle
            record.recordType = recordType
            record.summary = summary?.isEmpty == false ? summary : nil
            record.notes = notes?.isEmpty == false ? notes : nil
            record.providerName = providerName?.isEmpty == false ? providerName : nil
            record.dateRecorded = dateRecorded ?? Date()
            record.createdAt = Date()
            record.updatedAt = Date()
            record.medicalCase = medicalCase
            record.patient = patient
            
            try context.save()
            
            return record
        }
    }
    
    // MARK: - Lab Result Operations
    
    func createLabResult(
        caseID: UUID,
        patientID: UUID,
        testName: String,
        labName: String? = nil,
        category: String? = nil,
        status: String? = nil,
        resultDate: Date? = nil
    ) async throws -> LabResult {
        
        return try await performBackgroundTask { context in
            let trimmedTestName = testName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedTestName.isEmpty else {
                throw MedicalCaseError.invalidData("Test name cannot be empty")
            }
            
            // Find medical case and patient
            let caseFetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            caseFetch.predicate = NSPredicate(format: "id == %@", caseID as CVarArg)
            caseFetch.fetchLimit = 1
            
            let patientFetch = NSFetchRequest<Patient>(entityName: "Patient")
            patientFetch.predicate = NSPredicate(format: "id == %@", patientID as CVarArg)
            patientFetch.fetchLimit = 1
            
            guard let medicalCase = try context.fetch(caseFetch).first else {
                throw MedicalCaseError.caseNotFound
            }
            
            guard let patient = try context.fetch(patientFetch).first else {
                throw MedicalCaseError.patientNotFound
            }
            
            // Create lab result
            let labResult = LabResult(context: context)
            labResult.id = UUID()
            labResult.testName = trimmedTestName
            labResult.labName = labName?.isEmpty == false ? labName : nil
            labResult.category = category?.isEmpty == false ? category : nil
            labResult.status = status?.isEmpty == false ? status : nil
            labResult.resultDate = resultDate ?? Date()
            labResult.createdAt = Date()
            labResult.updatedAt = Date()
            labResult.medicalCase = medicalCase
            labResult.patient = patient
            
            try context.save()
            
            return labResult
        }
    }
    
    // MARK: - Document Operations
    
    func createDocument(
        caseID: UUID,
        patientID: UUID,
        fileName: String,
        documentType: String? = nil,
        fileURL: URL? = nil,
        fileSize: Int64 = 0,
        documentDate: Date? = nil
    ) async throws -> Document {
        
        return try await performBackgroundTask { context in
            let trimmedFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedFileName.isEmpty else {
                throw MedicalCaseError.invalidData("File name cannot be empty")
            }
            
            // Find medical case and patient
            let caseFetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            caseFetch.predicate = NSPredicate(format: "id == %@", caseID as CVarArg)
            caseFetch.fetchLimit = 1
            
            let patientFetch = NSFetchRequest<Patient>(entityName: "Patient")
            patientFetch.predicate = NSPredicate(format: "id == %@", patientID as CVarArg)
            patientFetch.fetchLimit = 1
            
            guard let medicalCase = try context.fetch(caseFetch).first else {
                throw MedicalCaseError.caseNotFound
            }
            
            guard let patient = try context.fetch(patientFetch).first else {
                throw MedicalCaseError.patientNotFound
            }
            
            // Create document
            let document = Document(context: context)
            document.id = UUID()
            document.fileName = trimmedFileName
            document.documentType = documentType?.isEmpty == false ? documentType : nil
            document.fileURL = fileURL
            document.fileSize = fileSize
            document.documentDate = documentDate
            document.uploadDate = Date()
            document.createdAt = Date()
            document.updatedAt = Date()
            document.medicalCase = medicalCase
            document.patient = patient
            
            try context.save()
            
            return document
        }
    }
    
    // MARK: - Calendar Event Operations
    
    func createCalendarEvent(
        caseID: UUID,
        patientID: UUID,
        title: String,
        startDate: Date,
        location: String? = nil,
        notes: String? = nil,
        eventType: String? = nil
    ) async throws -> CalendarEvent {
        
        return try await performBackgroundTask { context in
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedTitle.isEmpty else {
                throw MedicalCaseError.invalidData("Event title cannot be empty")
            }
            
            // Find medical case and patient
            let caseFetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            caseFetch.predicate = NSPredicate(format: "id == %@", caseID as CVarArg)
            caseFetch.fetchLimit = 1
            
            let patientFetch = NSFetchRequest<Patient>(entityName: "Patient")
            patientFetch.predicate = NSPredicate(format: "id == %@", patientID as CVarArg)
            patientFetch.fetchLimit = 1
            
            guard let medicalCase = try context.fetch(caseFetch).first else {
                throw MedicalCaseError.caseNotFound
            }
            
            guard let patient = try context.fetch(patientFetch).first else {
                throw MedicalCaseError.patientNotFound
            }
            
            // Create calendar event
            let event = CalendarEvent(context: context)
            event.id = UUID()
            event.title = trimmedTitle
            event.startDate = startDate
            event.location = location?.isEmpty == false ? location : nil
            event.notes = notes?.isEmpty == false ? notes : nil
            event.eventType = eventType?.isEmpty == false ? eventType : nil
            event.createdAt = Date()
            event.updatedAt = Date()
            event.medicalCase = medicalCase
            event.patient = patient
            
            try context.save()
            
            return event
        }
    }
    
    // MARK: - Helper Methods
    
    private func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            persistenceController.container.performBackgroundTask { context in
                do {
                    let result = try block(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Batch Operations
    
    func batchDeleteMedicalCases(for patientID: UUID) async throws {
        try await performBackgroundTask { context in
            let fetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            fetch.predicate = NSPredicate(format: "patient.id == %@", patientID as CVarArg)
            
            let cases = try context.fetch(fetch)
            for medicalCase in cases {
                context.delete(medicalCase)
            }
            
            try context.save()
        }
    }
    
    func getCaseCount(for patientID: UUID) async throws -> Int {
        return try await performBackgroundTask { context in
            let fetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            fetch.predicate = NSPredicate(format: "patient.id == %@", patientID as CVarArg)
            
            return try context.count(for: fetch)
        }
    }
    
    // MARK: - Search Operations
    
    func searchMedicalCases(query: String, patientID: UUID? = nil) async throws -> [MedicalCase] {
        return try await performBackgroundTask { context in
            var predicates: [NSPredicate] = [
                NSPredicate(format: "title CONTAINS[cd] %@ OR notes CONTAINS[cd] %@ OR treatmentPlan CONTAINS[cd] %@", query, query, query)
            ]
            
            if let patientID = patientID {
                predicates.append(NSPredicate(format: "patient.id == %@", patientID as CVarArg))
            }
            
            let fetch = NSFetchRequest<MedicalCase>(entityName: "MedicalCase")
            fetch.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetch.sortDescriptors = [
                NSSortDescriptor(keyPath: \MedicalCase.updatedAt, ascending: false)
            ]
            
            return try context.fetch(fetch)
        }
    }
}

// MARK: - Dependency Values
extension MedicalCaseService: DependencyKey {
    public static var liveValue: MedicalCaseService {
        MedicalCaseService.shared
    }
}

extension DependencyValues {
    var medicalCaseService: MedicalCaseService {
        get { self[MedicalCaseService.self] }
        set { self[MedicalCaseService.self] = newValue }
    }
}
