//
//  MedicationScheduleServiceProtocol.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation
import Combine

/// Protocol defining the interface for medication schedule services
protocol MedicationScheduleServiceProtocol: AnyObject {
    
    // MARK: - Properties
    
    /// Current date for scheduling calculations
    var currentDate: Date { get set }
    
    /// Current scheduled doses organized by time slot
    var timelineDoses: [TimeSlot: [ScheduledDose]] { get }
    
    /// All scheduled doses for the current day
    var todaysDoses: [ScheduledDose] { get }
    
    /// Publisher for schedule updates
    var scheduleUpdatePublisher: AnyPublisher<Void, Never> { get }
    
    // MARK: - Methods
    
    /// Update medications and regenerate schedule
    func updateMedications(_ medications: [Medication]) -> MedicationScheduleResult<Void>
    
    /// Generate medication schedule for a specific date
    func generateSchedule(for date: Date) -> MedicationScheduleResult<Void>
    
    /// Mark a dose with the specified status
    func updateDoseStatus(_ dose: ScheduledDose, to status: DoseStatus, takenTime: Date?) -> MedicationScheduleResult<ScheduledDose>
    
    /// Get doses for a specific time slot
    func doses(for timeSlot: TimeSlot) -> [ScheduledDose]
    
    /// Get overdue doses
    func getOverdueDoses() -> [ScheduledDose]
    
    /// Get upcoming doses within specified hours
    func getUpcomingDoses(within hours: Int) -> [ScheduledDose]
    
    /// Calculate schedule metrics
    func calculateMetrics() -> ScheduleMetrics
    
    /// Validate medication data
    func validateMedication(_ medication: Medication) -> MedicationScheduleResult<Void>
}

/// Default implementations for common functionality
extension MedicationScheduleServiceProtocol {
    
    /// Mark a dose as taken
    func markDoseAsTaken(_ dose: ScheduledDose) -> MedicationScheduleResult<ScheduledDose> {
        return updateDoseStatus(dose, to: .taken, takenTime: Date())
    }
    
    /// Mark a dose as missed
    func markDoseAsMissed(_ dose: ScheduledDose) -> MedicationScheduleResult<ScheduledDose> {
        return updateDoseStatus(dose, to: .missed, takenTime: nil)
    }
    
    /// Mark a dose as skipped
    func markDoseAsSkipped(_ dose: ScheduledDose) -> MedicationScheduleResult<ScheduledDose> {
        return updateDoseStatus(dose, to: .skipped, takenTime: nil)
    }
    
    /// Get upcoming doses with default 2-hour window
    func getUpcomingDoses() -> [ScheduledDose] {
        return getUpcomingDoses(within: 2)
    }
}