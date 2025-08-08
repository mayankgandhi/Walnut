# Atlas

Atlas is a healthcare management iOS application built with SwiftUI and Tuist, designed to demonstrate the usage of the Walnut Design System and AIKit frameworks.

## Overview

Atlas serves as a showcase application for healthcare-focused UI components and demonstrates how to build a modern iOS app using:

- **WalnutDesignSystem**: Rich, healthcare-focused UI components
- **AIKit**: AI-powered healthcare features
- **SwiftUI**: Modern declarative UI framework
- **Tuist**: Project generation and management

## Features

### Patient Information Management
- Patient profile with completion tracking
- Blood type selection with validation
- Date of birth picker with age calculation
- Emergency contact information
- Notification preferences

### Healthcare UI Components
- **TextFieldItem**: Elegant text input fields with validation
- **MenuPickerItem**: Dropdown menus for selections
- **DatePickerItem**: Date/time selection with modal presentation
- **ToggleItem**: Switch controls for settings
- **MenuListItem**: Rich list items with icons and badges
- **ProfileHeader**: Patient profile display with health status

### Design Features
- Subtle, professional color palette
- Consistent spacing and typography using design tokens
- Validation states with visual feedback
- Press animations and micro-interactions
- Material Design backgrounds with subtle shadows

## Project Structure

```
Atlas/
├── Sources/
│   ├── AtlasApp.swift          # Main app entry point
│   ├── ContentView.swift       # Primary app view
│   └── Models/
│       └── HealthcareModels.swift  # Data models
├── Tests/
│   ├── AtlasTests.swift        # Basic app tests
│   └── HealthcareModelTests.swift  # Model validation tests
├── Resources/
│   └── LaunchScreen.storyboard # Launch screen
└── Project.swift               # Tuist project configuration
```

## Dependencies

- **WalnutDesignSystem**: Local dependency for healthcare UI components
- **AIKit**: External dependency for AI-powered features

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Tuist 4.0+

## Getting Started

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Walnut/Atlas
   ```

2. **Generate the project**
   ```bash
   tuist generate
   ```

3. **Open in Xcode**
   ```bash
   open Atlas.xcworkspace
   ```

4. **Build and run**
   - Select the Atlas scheme
   - Choose your target device/simulator
   - Press Cmd+R to build and run

## Testing

The project includes comprehensive unit tests:

- **AtlasTests**: Basic app functionality tests
- **HealthcareModelTests**: Model validation and business logic tests

Run tests with:
```bash
# In Xcode: Cmd+U
# Or via command line:
xcodebuild test -workspace Atlas.xcworkspace -scheme Atlas
```

## Healthcare Data Models

### Patient
- Unique ID generation
- Personal information (name, DOB, blood type)
- Emergency contact details
- Notification preferences
- Profile completion tracking
- Age calculation from date of birth

### BloodType
- All standard blood types (A+, A-, B+, B-, O+, O-, AB+, AB-)
- Universal donor/receiver identification
- CaseIterable for picker support

### NotificationSettings
- Medication reminders
- Appointment alerts
- Health tip notifications
- Emergency alerts (always enabled for safety)

### HealthStatus
- Four levels: Excellent, Good, Fair, Needs Attention
- Integration with ProfileHeader component
- Display name formatting

## Design Philosophy

Atlas demonstrates healthcare app design principles:

- **Trust & Professionalism**: Subtle colors and clean design
- **Accessibility**: Proper contrast ratios and touch targets
- **Clarity**: Clear visual hierarchy and readable typography
- **Safety**: Emergency features always enabled
- **Validation**: Immediate feedback on data entry
- **Consistency**: Unified design language across components

## License

Copyright © 2025 m. All rights reserved.