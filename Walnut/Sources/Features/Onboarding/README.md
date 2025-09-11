# Onboarding Flow

A comprehensive onboarding flow for the Walnut medical app built with SwiftUI and following the existing design patterns.

## Structure

```
Onboarding/
├── OnboardingContainerView.swift      # Main container with page navigation
├── OnboardingViewModel.swift          # @Observable view model for state management
├── OnboardingIntegrationExample.swift # Example integration
├── Models/
│   └── OnboardingModels.swift        # Data models and enums
└── Screens/
    ├── WelcomeScreen.swift           # App value proposition
    ├── HealthProfileScreen.swift     # Chronic conditions & emergency contacts
    ├── PermissionsScreen.swift       # System permissions
    ├── PatientSetupScreen.swift      # Patient information
    ├── VitalsIntroductionScreen.swift # Vitals tracking features
    └── CompletionScreen.swift        # Celebration & summary
```

## Key Features

### Architecture
- Uses @Observable pattern for state management
- SwiftUI TabView with PageTabViewStyle for smooth transitions
- Component-driven design with reusable UI elements
- Integration with existing WalnutDesignSystem

### Screens
1. **Welcome**: Introduces app value proposition with feature highlights
2. **Health Profile**: Collects chronic conditions and emergency contact info
3. **Permissions**: Requests notifications and health data access
4. **Patient Setup**: Gathers patient demographics using existing Patient model
5. **Vitals Introduction**: Showcases health tracking capabilities
6. **Completion**: Celebrates completion and creates patient record

### Design System Integration
- Uses HealthCard for consistent card styling
- Leverages DSButton for all actions
- Follows Spacing constants throughout
- Implements health-specific colors (.healthPrimary, .healthSuccess, etc.)
- Maintains accessibility standards

### Data Flow
- Collects data progressively across screens
- Validates required fields before allowing progression
- Creates Patient record on completion
- Stores completion status in UserDefaults
- Posts notification when onboarding completes

## Usage

```swift
struct YourApp: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainAppView()
            } else {
                OnboardingContainerView {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}
```

## Customization

The onboarding flow is designed to be easily customizable:

- Add/remove screens by updating the OnboardingScreen enum
- Modify chronic conditions in the ChronicCondition enum  
- Customize validation logic in OnboardingViewModel
- Add new permission types to AppPermissions struct
- Style individual screens while maintaining design consistency

## Dependencies

- SwiftUI
- SwiftData (for Patient model integration)
- UserNotifications (for permission requests)
- WalnutDesignSystem (for UI components)

## Notes

- All screens support both light and dark mode
- Proper keyboard handling and form validation
- Smooth animations between screens
- Accessibility labels and support
- Error handling and validation feedback
- Integration with existing Patient SwiftData model