//
//  DataRepository.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//

import CoreData
import Foundation
import Combine

// MARK: - Data Repository Protocol
protocol DataRepositoryProtocol {
    func createPatient(firstName: String, lastName: String, dateOfBirth: Date?) -> Patient
    func fetchPatients() -> [Patient]
    func fetchActivePatients() -> [Patient]
    func deletePatient(_ patient: Patient)
    
    func createLabResult(for patient: Patient, testName: String, date: Date) -> LabResult
    func fetchLabResults(for patient: Patient) -> [LabResult]
    func fetchRecentLabResults(limit: Int) -> [LabResult]
    
    func createDocument(fileName: String, fileURL: URL, for patient: Patient) -> Document
    func fetchDocuments(for patient: Patient) -> [Document]
    
    func save()
}

// MARK: - Core Data Repository Implementation
class CoreDataRepository: DataRepositoryProtocol, ObservableObject {
    private let persistenceController: PersistenceController
    private var cancellables = Set<AnyCancellable>()
    
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        
        // Listen for context changes
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Patient Operations
    
    func createPatient(firstName: String, lastName: String, dateOfBirth: Date? = nil) -> Patient {
        let patient = Patient(context: viewContext, firstName: firstName, lastName: lastName)
        patient.dateOfBirth = dateOfBirth
        save()
        return patient
    }
    
    func fetchPatients() -> [Patient] {
        return viewContext.fetch(Patient.self, sortDescriptors: [
            NSSortDescriptor(keyPath: \Patient.lastName, ascending: true),
            NSSortDescriptor(keyPath: \Patient.firstName, ascending: true)
        ])
    }
    
    func fetchActivePatients() -> [Patient] {
        let predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        return viewContext.fetch(Patient.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \Patient.lastName, ascending: true)
        ])
    }
    
    func updatePatient(_ patient: Patient) {
        patient.updatedAt = Date()
        save()
    }
    
    func deletePatient(_ patient: Patient) {
        viewContext.delete(patient)
        save()
    }
    
    // MARK: - Lab Result Operations
    
    func createLabResult(for patient: Patient, testName: String, date: Date = Date()) -> LabResult {
        let labResult = LabResult(context: viewContext, testName: testName, patient: patient)
        labResult.resultDate = date
        save()
        return labResult
    }
    
    func fetchLabResults(for patient: Patient) -> [LabResult] {
        let predicate = NSPredicate(format: "patient == %@", patient)
        return viewContext.fetch(LabResult.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \LabResult.resultDate, ascending: false)
        ])
    }
    
    func fetchRecentLabResults(limit: Int = 10) -> [LabResult] {
        let request = NSFetchRequest<LabResult>(entityName: "LabResult")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \LabResult.resultDate, ascending: false)]
        request.fetchLimit = limit
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching recent lab results: \(error)")
            return []
        }
    }
    
    func updateLabResult(_ labResult: LabResult) {
        labResult.updatedAt = Date()
        save()
    }
    
    func deleteLabResult(_ labResult: LabResult) {
        viewContext.delete(labResult)
        save()
    }
    
    // MARK: - Test Result Operations
    
    func createTestResult(for labResult: LabResult, markerName: String, value: String, unit: String? = nil) -> TestResult {
        let testResult = TestResult(context: viewContext, markerName: markerName, value: value, labResult: labResult)
        testResult.unit = unit
        save()
        return testResult
    }
    
    func fetchTestResults(for labResult: LabResult) -> [TestResult] {
        let predicate = NSPredicate(format: "labResult == %@", labResult)
        return viewContext.fetch(TestResult.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \TestResult.markerName, ascending: true)
        ])
    }
    
    func fetchTestResults(for patient: Patient, markerName: String) -> [TestResult] {
        let predicate = NSPredicate(format: "patient == %@ AND markerName == %@", patient, markerName)
        return viewContext.fetch(TestResult.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \TestResult.createdAt, ascending: false)
        ])
    }
    
    // MARK: - Document Operations
    
    func createDocument(fileName: String, fileURL: URL, for patient: Patient) -> Document {
        let document = Document(context: viewContext, fileName: fileName, fileURL: fileURL, patient: patient)
        
        // Set file size
        if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let fileSize = attributes[.size] as? Int64 {
            document.fileSize = fileSize
        }
        
        save()
        return document
    }
    
    func fetchDocuments(for patient: Patient) -> [Document] {
        let predicate = NSPredicate(format: "patient == %@", patient)
        return viewContext.fetch(Document.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \Document.uploadDate, ascending: false)
        ])
    }
    
    func fetchAllDocuments() -> [Document] {
        return viewContext.fetch(Document.self, sortDescriptors: [
            NSSortDescriptor(keyPath: \Document.uploadDate, ascending: false)
        ])
    }
    
    func updateDocument(_ document: Document) {
        save()
    }
    
    func deleteDocument(_ document: Document) {
        viewContext.delete(document)
        save()
    }
    
    // MARK: - Medical Record Operations
    
    func createMedicalRecord(recordType: String, title: String, for patient: Patient) -> MedicalRecord {
        let record = MedicalRecord(context: viewContext, recordType: recordType, title: title, patient: patient)
        save()
        return record
    }
    
    func fetchMedicalRecords(for patient: Patient) -> [MedicalRecord] {
        let predicate = NSPredicate(format: "patient == %@", patient)
        return viewContext.fetch(MedicalRecord.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \MedicalRecord.date, ascending: false)
        ])
    }
    
    func fetchMedicalRecords(ofType recordType: String) -> [MedicalRecord] {
        let predicate = NSPredicate(format: "recordType == %@", recordType)
        return viewContext.fetch(MedicalRecord.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \MedicalRecord.date, ascending: false)
        ])
    }
    
    func updateMedicalRecord(_ record: MedicalRecord) {
        record.updatedAt = Date()
        save()
    }
    
    func deleteMedicalRecord(_ record: MedicalRecord) {
        viewContext.delete(record)
        save()
    }
    
    // MARK: - Tag Operations
    
    func createTag(name: String, color: String? = nil) -> Tag {
        let tag = Tag(context: viewContext, name: name, color: color)
        save()
        return tag
    }
    
    func fetchTags() -> [Tag] {
        return viewContext.fetch(Tag.self, sortDescriptors: [
            NSSortDescriptor(keyPath: \Tag.name, ascending: true)
        ])
    }
    
    func fetchTag(withName name: String) -> Tag? {
        let predicate = NSPredicate(format: "name == %@", name)
        return viewContext.fetch(Tag.self, predicate: predicate).first
    }
    
    func deleteTag(_ tag: Tag) {
        viewContext.delete(tag)
        save()
    }
    
    // MARK: - Search Operations
    
    func searchPatients(query: String) -> [Patient] {
        let predicate = NSPredicate(format: "firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", query, query)
        return viewContext.fetch(Patient.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \Patient.lastName, ascending: true)
        ])
    }
    
    func searchDocuments(query: String) -> [Document] {
        let predicate = NSPredicate(format: "fileName CONTAINS[cd] %@", query)
        return viewContext.fetch(Document.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \Document.uploadDate, ascending: false)
        ])
    }
    
    func searchLabResults(query: String) -> [LabResult] {
        let predicate = NSPredicate(format: "testName CONTAINS[cd] %@ OR labName CONTAINS[cd] %@", query, query)
        return viewContext.fetch(LabResult.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \LabResult.resultDate, ascending: false)
        ])
    }
    
    // MARK: - Analytics Operations
    
    func getPatientCount() -> Int {
        return viewContext.count(Patient.self)
    }
    
    func getActivePatientCount() -> Int {
        let predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        return viewContext.count(Patient.self, predicate: predicate)
    }
    
    func getLabResultCount(for patient: Patient) -> Int {
        let predicate = NSPredicate(format: "patient == %@", patient)
        return viewContext.count(LabResult.self, predicate: predicate)
    }
    
    func getDocumentCount(for patient: Patient) -> Int {
        let predicate = NSPredicate(format: "patient == %@", patient)
        return viewContext.count(Document.self, predicate: predicate)
    }
    
    func getAbnormalLabResults() -> [LabResult] {
        let predicate = NSPredicate(format: "status == %@ OR status == %@", "abnormal", "critical")
        return viewContext.fetch(LabResult.self, predicate: predicate, sortDescriptors: [
            NSSortDescriptor(keyPath: \LabResult.resultDate, ascending: false)
        ])
    }
    
    // MARK: - Batch Operations
    
    func batchUpdatePatients(predicate: NSPredicate, updates: [String: Any]) async throws {
        try await persistenceController.performBackgroundTask { context in
            let request = NSBatchUpdateRequest(entityName: "Patient")
            request.predicate = predicate
            request.propertiesToUpdate = updates
            request.resultType = .updatedObjectIDsResultType
            
            do {
                let result = try context.execute(request) as? NSBatchUpdateResult
                let objectIDs = result?.result as? [NSManagedObjectID] ?? []
                
                let changes = [NSUpdatedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                
                try context.save()
            } catch {
                throw error
            }
        }
    }
    
    // MARK: - Core Data Operations
    
    func save() {
        viewContext.saveWithErrorHandling()
    }
    
    func refresh(_ object: NSManagedObject) {
        viewContext.refresh(object, mergeChanges: true)
    }
    
    func rollback() {
        viewContext.rollback()
    }
    
    // MARK: - Background Context Operations
    
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) -> T) async throws -> T {
        return try await persistenceController.performBackgroundTask(block)
    }
}

// MARK: - Repository Dependency Injection
extension CoreDataRepository {
    static let shared = CoreDataRepository()
}
