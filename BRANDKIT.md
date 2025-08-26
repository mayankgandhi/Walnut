# Walnut Brand Kit
*Healthcare Management App*

---

## 🏥 Brand Identity

### Mission Statement
Walnut empowers patients and healthcare providers with intuitive, comprehensive medical records management. We believe healthcare data should be accessible, organized, and actionable.

### Vision
To become the leading personal healthcare management platform that bridges the gap between patients, providers, and medical data.

### Values
- **Trust**: Secure, reliable healthcare data management
- **Simplicity**: Intuitive design that reduces complexity
- **Care**: Patient-centered approach to health tracking
- **Innovation**: Leveraging AI for better health outcomes

---

## 🎨 Visual Identity

### Logo & Icon
- **Primary Icon**: `heart.text.square.fill` (SF Symbol)
- **App Icon**: Rounded square with health-focused symbolism
- **Usage**: The heart symbol represents care and health, while the text element signifies medical records and documentation

### Color Palette

#### Primary Colors
```
Health Primary: #4ECDC4 (Teal)
- RGB: 78, 205, 196
- HSL: 176°, 58%, 55%
- Usage: Primary actions, headers, key UI elements
```

#### Secondary Colors
```
Health Success: #96CEB4 (Mint Green)
- Usage: Success states, completed actions, positive indicators

Health Warning: #FFEAA7 (Soft Yellow)
- Usage: Warnings, pending states, attention items

Health Error: #FF6B6B (Coral Red)
- Usage: Error states, critical alerts, important warnings
```

#### Extended Palette
```
Accent Colors (Patient Theming):
- Coral: #FF6B6B
- Teal: #4ECDC4
- Sky Blue: #45B7D1
- Mint: #96CEB4
- Cream: #FFEAA7
- Lavender: #DDA0DD
- Sage: #98D8C8
- Gold: #F7DC6F
- Purple: #BB8FCE
- Light Blue: #85C1E9
```

#### System Colors
```
Background: System Background
Secondary Background: System Secondary Background
Tertiary Background: System Tertiary Background
Text Primary: System Label
Text Secondary: System Secondary Label
```

---

## 📱 Typography

### Hierarchy
```
Display: .largeTitle (34pt, Bold)
- Usage: App name, major section headers

Headline: .title (.title2, .title3) (20-28pt, Semibold)
- Usage: Screen titles, section headers, card titles

Body: .headline, .body (16-17pt, Regular/Medium)
- Usage: Primary content, descriptions, form labels

Detail: .subheadline, .footnote, .caption (12-15pt, Regular/Medium)
- Usage: Secondary information, metadata, helper text

Health Metrics: Custom health-specific typography
- .healthMetricLarge: Large numerical displays
- .healthMetricMedium: Standard metric displays  
- .healthMetricSmall: Compact metric displays
```

### Font Weights
- **Bold**: Major headlines, important actions
- **Semibold**: Section headers, emphasized content
- **Medium**: Interactive elements, labels
- **Regular**: Body text, descriptions

---

## 🧩 Design System Components

### Spacing Scale
```
.xs: 4pt    - Tight spacing, fine details
.small: 8pt - Close related elements  
.medium: 16pt - Standard spacing
.large: 24pt - Section separation
.xl: 32pt - Major layout spacing
```

### Corner Radius
```
Small: 8pt - Buttons, small cards
Medium: 12pt - Standard cards, inputs
Large: 16pt - Major containers
Extra Large: 20pt - Hero elements
```

### Elevation & Shadows
```
Card Shadow: 0px 2px 8px rgba(0,0,0,0.1)
Button Shadow: 0px 1px 3px rgba(0,0,0,0.12)
Modal Shadow: 0px 8px 32px rgba(0,0,0,0.15)
```

---

## 🎯 Component Patterns

### Cards
- **HealthCard**: Primary container with subtle shadow and rounded corners
- **PatientAvatar**: Circular avatar with patient initials and color theming
- **StatusIndicator**: Visual status representation with color coding
- **MedicationCard**: Specialized card for medication display

### Navigation
- **Clean hierarchy**: Clear visual hierarchy with proper spacing
- **Native patterns**: Following iOS Human Interface Guidelines
- **Contextual actions**: Action buttons placed logically in context

### Data Display
- **HealthMetric**: Numerical health data with proper typography
- **BiomarkerDetailView**: Complex health data visualization
- **LineChart**: Time-series health data visualization

---

## 🏥 Health-Specific Guidelines

### Medical Information Display
- **Blood Type**: Use red accent color (#FF6B6B)
- **Medications**: Use success green for active, warning yellow for upcoming
- **Emergency Contacts**: Use blue accent for contact information
- **Allergies**: Use warning orange for allergy indicators

### Status Indicators
```
Active Patient: Green circle with "Active" label
Inactive Patient: Gray circle with "Inactive" label
Medication Due: Orange/Yellow warning state
Medication Taken: Green success state
Critical Alert: Red error state
```

### Iconography
- **Medical Records**: `doc.text.fill`
- **Medications**: `pills.fill`, `cross.case.fill`
- **Appointments**: `calendar.badge.clock`
- **Emergency**: `phone.fill.arrow.up.right`
- **Health Metrics**: `heart.text.square.fill`
- **Blood Type**: `drop.fill`
- **Allergies**: `exclamationmark.triangle.fill`

---

## 📐 Layout Guidelines

### Grid System
- **Mobile**: 16pt margins with flexible content areas
- **Tablet**: Adaptive layouts with responsive breakpoints
- **Spacing**: Consistent 8pt grid system

### Content Organization
- **Card-based**: Information grouped in digestible cards
- **Hierarchical**: Clear information architecture
- **Scannable**: Easy to scan and find relevant information

### Accessibility
- **Color Contrast**: Minimum 4.5:1 ratio for text
- **Touch Targets**: Minimum 44pt touch targets
- **Text Size**: Support for Dynamic Type scaling
- **VoiceOver**: Proper semantic labeling

---

## 🎨 Usage Examples

### Primary Actions
```swift
Button("Save Patient") { }
    .foregroundStyle(.white)
    .padding()
    .background(.healthPrimary)
    .clipShape(Capsule())
```

### Status Display
```swift
StatusIndicator(isActive: patient.isActive)
HealthMetric(title: "Blood Pressure", value: "120/80", unit: "mmHg")
```

### Cards
```swift
HealthCard {
    VStack(spacing: .medium) {
        PatientAvatar(initials: "JD", color: .healthPrimary)
        Text("Patient Information")
    }
}
```

---

## 🚀 Implementation Notes

### Design System Integration
- All components use `WalnutDesignSystem` framework
- Consistent spacing with `Spacing` constants
- Health-specific colors with `.health*` semantic names
- Typography hierarchy with health metric styles

### Patient Personalization
- Each patient has a randomly assigned theme color
- Colors persist across sessions for consistency
- 20 predefined color options for variety

### Platform Considerations
- iOS-first design following Apple's HIG
- SwiftUI native implementation
- Support for iOS 17+ features and styling

---

## 📋 Brand Applications

### App Store Presence
- **App Name**: Walnut
- **Subtitle**: Healthcare Management
- **Category**: Medical
- **Keywords**: health records, medical tracking, patient care, medication management

### Marketing Materials
- **Primary Color**: Health Primary (#4ECDC4)
- **Logo Placement**: Always with adequate breathing room
- **Photography**: Clean, medical environment imagery
- **Tone**: Professional yet approachable

---

*Last Updated: August 2025*
*Version: 1.0*