# MedicationTracker Architecture

## Overview

The MedicationTracker feature has been refactored to follow clean architecture principles with clear separation of concerns, dependency injection, and protocol-based design for improved testability and maintainability.

## Directory Structure

```
MedicationTracker/
├── AllMedicationsView.swift                 # Main view - refactored and simplified
├── Components/                              # Reusable UI components
│   ├── Schedule/
│   │   ├── MedicationScheduleHeader.swift  # Date selector and metrics header
│   │   └── MedicationEmptyState.swift      # Empty state view
│   └── MedicationTimelineView.swift        # Timeline display components
├── Services/                               # Business logic services
│   ├── MedicationScheduleService.swift     # Main scheduling service
│   └── MedicationDependencyContainer.swift # Dependency injection container
├── Protocols/                              # Service interfaces
│   └── MedicationScheduleServiceProtocol.swift # Service protocol definition
├── Models/                                 # Data models and extensions
│   ├── MedicationScheduleError.swift       # Error handling
│   └── MedicationScheduleModels.swift      # Enhanced data models
└── ARCHITECTURE.md                         # This documentation
```

## Key Architectural Improvements

### 1. **Separation of Concerns**

- **UI Layer**: Views focus purely on presentation and user interaction
- **Service Layer**: Business logic isolated in protocol-based services
- **Model Layer**: Data structures and domain logic separated from UI

### 2. **Protocol-Based Design**

```swift
protocol MedicationScheduleServiceProtocol {
    var timelineDoses: [TimeSlot: [ScheduledDose]] { get }
    var todaysDoses: [ScheduledDose] { get }
    
    func updateMedications(_ medications: [Medication]) -> MedicationScheduleResult<Void>
    func generateSchedule(for date: Date) -> MedicationScheduleResult<Void>
    func updateDoseStatus(_ dose: ScheduledDose, to status: DoseStatus, takenTime: Date?) -> MedicationScheduleResult<ScheduledDose>
}
```

### 3. **Error Handling**

Comprehensive error handling with typed errors and user-friendly messages:

```swift
enum MedicationScheduleError: LocalizedError {
    case invalidMedication
    case invalidFrequency  
    case schedulingFailed
    case doseUpdateFailed
    // ... with localized descriptions and recovery suggestions
}
```

### 4. **Dependency Injection**

Centralized dependency management for better testability:

```swift
final class MedicationDependencyContainer {
    static let shared = MedicationDependencyContainer()
    
    func registerScheduleService(_ factory: @escaping () -> MedicationScheduleServiceProtocol)
    func resolveScheduleService() -> MedicationScheduleServiceProtocol
}
```

### 5. **Component Extraction**

- `MedicationScheduleHeader`: Date selection and summary metrics
- `MedicationEmptyState`: Reusable empty state with action callbacks
- `MedicationTimelineView`: Complex timeline rendering (pre-existing)

### 6. **Enhanced Data Models**

Extended existing models with computed properties and utility methods:

```swift
extension ScheduledDose {
    var timeUntilDue: TimeInterval { /* ... */ }
    var isDueSoon: Bool { /* ... */ }
    var timeDescription: String { /* ... */ }
}
```

## Usage Patterns

### Dependency Injection in Views

```swift
struct AllMedicationsView: View {
    init(patient: Patient, container: MedicationDependencyContainer = .shared) {
        self.patient = patient
        self.scheduleService = container.resolveScheduleService()
    }
}
```

### Error Handling in Services

```swift
func updateMedications(_ medications: [Medication]) -> MedicationScheduleResult<Void> {
    // Validate medications first
    for medication in medications {
        if case .failure(let error) = validateMedication(medication) {
            return .failure(error)
        }
    }
    
    // Perform update...
    return .success(())
}
```

### Reactive Updates

```swift
var scheduleUpdatePublisher: AnyPublisher<Void, Never> {
    scheduleUpdateSubject.eraseToAnyPublisher()
}
```

## Testing Strategy

The refactored architecture enables comprehensive testing:

1. **Unit Testing**: Protocol-based services can be easily mocked
2. **Integration Testing**: Dependency injection allows testing with real/mock dependencies
3. **UI Testing**: Extracted components can be tested in isolation

### Example Test Setup

```swift
class MockMedicationScheduleService: MedicationScheduleServiceProtocol {
    // Mock implementation for testing
}

// In tests
let mockService = MockMedicationScheduleService()
let container = MedicationDependencyContainer()
container.registerScheduleService { mockService }

let view = AllMedicationsView(patient: testPatient, container: container)
```

## Performance Optimizations

1. **Lazy Loading**: Timeline components use LazyVStack for efficient scrolling
2. **Computed Properties**: Metrics calculated on-demand
3. **Publisher-Based Updates**: Reactive updates minimize unnecessary re-renders
4. **Memory Management**: Weak references and proper cleanup

## Migration Guide

### Before Refactoring
- 258-line monolithic view with mixed responsibilities
- Direct service instantiation making testing difficult
- No error handling for edge cases
- Code duplication across components

### After Refactoring  
- Clean separation between UI, business logic, and data
- Protocol-based architecture enabling easy testing and mocking
- Comprehensive error handling with user feedback
- Reusable components reducing code duplication
- Dependency injection for flexible configuration

## Future Enhancements

The new architecture supports these future improvements:

1. **Caching Layer**: Add persistence service for dose history
2. **Background Sync**: Integrate with health data synchronization
3. **Analytics**: Track medication adherence patterns
4. **Notifications**: Local notification scheduling service
5. **Offline Support**: Local storage for medication schedules

## Best Practices

1. Always use the protocol types in function signatures
2. Handle all error cases with user-friendly messages
3. Extract reusable components when UI patterns repeat
4. Use dependency injection for services in tests
5. Keep business logic in services, not in views
6. Follow the established naming conventions and file organization