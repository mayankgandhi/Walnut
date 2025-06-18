//
//  PatientRepository.swift
//  Walnut
//
//  Created by Mayank Gandhi on 07/06/25.
//

import CoreData
import Foundation
import Combine
import Dependencies

// MARK: - Data Repository Protocol
protocol PatientRepositoryProtocol {
    
    func createPatient(
        firstName: String,
        lastName: String,
        dateOfBirth: Date?,
        gender: String?,
        bloodType: String?,
        emergencyContactName: String?,
        emergencyContactPhone: String?,
        notes: String?,
        isActive: Bool
    ) throws -> Patient
    
    func fetchPatients() throws -> [Patient]
    func fetchActivePatients() throws -> [Patient]
    
    func searchPatients(query: String) throws -> [Patient]
    
    func deletePatient(_ patient: Patient) throws
}

// MARK: - Core Data Repository Implementation
class PatientRepository: PatientRepositoryProtocol, ObservableObject {
    
    static let shared = PatientRepository()
    
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
    
    // MARK: - Patient Operations
    
    func createPatient(
        firstName: String,
        lastName: String,
        dateOfBirth: Date? = nil,
        gender: String? = nil,
        bloodType: String? = nil,
        emergencyContactName: String? = nil,
        emergencyContactPhone: String? = nil,
        notes: String? = nil,
        isActive: Bool = true
    ) throws -> Patient {
        
        // Validate input data
        let trimmedFirstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFirstName.isEmpty else {
            throw PatientError.invalidData("First name cannot be empty")
        }
        
        guard !trimmedLastName.isEmpty else {
            throw PatientError.invalidData("Last name cannot be empty")
        }
        
        // Check for duplicate patient
        if let dateOfBirth = dateOfBirth {
            let duplicateCheck = try checkForDuplicatePatient(
                firstName: trimmedFirstName,
                lastName: trimmedLastName,
                dateOfBirth: dateOfBirth
            )
            
            if duplicateCheck {
                throw PatientError.duplicatePatient
            }
        }
        
        // Validate blood type if provided
        if let bloodType = bloodType, !bloodType.isEmpty {
            let validBloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"]
            if !validBloodTypes.contains(bloodType) {
                throw PatientError.invalidData("Invalid blood type")
            }
        }
        
        // Validate phone number format if provided
        if let phone = emergencyContactPhone, !phone.isEmpty {
            if !isValidPhoneNumber(phone) {
                throw PatientError.invalidData("Invalid phone number format")
            }
        }
        
        do {
            let patient = Patient(context: viewContext)
            patient.id = UUID()
            patient.firstName = trimmedFirstName
            patient.lastName = trimmedLastName
            patient.dateOfBirth = dateOfBirth
            patient.gender = gender
            patient.bloodType = bloodType
            patient.emergencyContactName = emergencyContactName
            patient.emergencyContactPhone = emergencyContactPhone
            patient.notes = notes
            patient.isActive = isActive
            patient.createdAt = Date()
            patient.updatedAt = Date()
            
            try save()
            return patient
            
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain {
                throw PatientError.databaseError
            } else {
                throw PatientError.unknown(error.localizedDescription)
            }
        }
    }
    
    func fetchPatients() throws -> [Patient] {
        do {
            return viewContext.fetch(Patient.self, sortDescriptors: [
                NSSortDescriptor(keyPath: \Patient.lastName, ascending: true),
                NSSortDescriptor(keyPath: \Patient.firstName, ascending: true)
            ])
        } catch {
            throw PatientError.databaseError
        }
    }
    
    func fetchActivePatients() throws -> [Patient] {
        do {
            let predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
            return viewContext.fetch(Patient.self, predicate: predicate, sortDescriptors: [
                NSSortDescriptor(keyPath: \Patient.lastName, ascending: true)
            ])
        } catch {
            throw PatientError.databaseError
        }
    }
    
    func updatePatient(_ patient: Patient) throws {
        do {
            patient.updatedAt = Date()
            try save()
        } catch {
            throw PatientError.databaseError
        }
    }
    
    func deletePatient(_ patient: Patient) throws {
        do {
            viewContext.delete(patient)
            try save()
        } catch {
            throw PatientError.databaseError
        }
    }
    
    func searchPatients(query: String) throws -> [Patient] {
        do {
            let predicate = NSPredicate(format: "firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@", query, query)
            return viewContext.fetch(Patient.self, predicate: predicate, sortDescriptors: [
                NSSortDescriptor(keyPath: \Patient.lastName, ascending: true)
            ])
        } catch {
            throw PatientError.databaseError
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkForDuplicatePatient(firstName: String, lastName: String, dateOfBirth: Date) throws -> Bool {
        let predicate = NSPredicate(
            format: "firstName ==[cd] %@ AND lastName ==[cd] %@ AND dateOfBirth == %@",
            firstName, lastName, dateOfBirth as NSDate
        )
        
        do {
            let existingPatients = viewContext.fetch(Patient.self, predicate: predicate)
            return !existingPatients.isEmpty
        } catch {
            throw PatientError.databaseError
        }
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^[\\+]?[1-9]?[0-9]{7,12}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: ""))
    }
    
    func getPatientCount() -> Int {
        return viewContext.count(Patient.self)
    }
    
    func getActivePatientCount() -> Int {
        let predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        return viewContext.count(Patient.self, predicate: predicate)
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
                throw PatientError.databaseError
            }
        }
    }
    
    // MARK: - Core Data Operations
    
    private func save() throws {
        do {
            if viewContext.hasChanges {
                try viewContext.save()
            }
        } catch let error as NSError {
            throw PatientError.databaseError
        }
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

// MARK: - Dependency Values
extension PatientRepository: DependencyKey {
    public static var liveValue: PatientRepository {
        PatientRepository()
    }
}

extension DependencyValues {
    var patientRepository: PatientRepository {
        get { self[PatientRepository.self] }
        set { self[PatientRepository.self] = newValue }
    }
}
