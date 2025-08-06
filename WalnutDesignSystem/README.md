# WalnutDesignSystem

A simple, accessible healthcare design system for iOS built with SwiftUI, following KISS and YAGNI principles.

## Overview

WalnutDesignSystem provides healthcare-focused UI components that match the reference designs while maintaining simplicity and accessibility. The design system follows modern iOS 17+ patterns with native materials and automatic light/dark mode support.

## Design Principles

- **KISS**: Direct SwiftUI APIs only, no complex abstractions
- **YAGNI**: Only essential components, nothing extra
- **Accessibility**: High contrast colors, 44pt minimum touch targets
- **Performance**: Lightweight, native animations only
- **Modern iOS**: iOS 17+ patterns with native materials

## Components

### Atoms (Basic Components)

#### Colors & Design Tokens
- `Color.healthPrimary` - Primary healthcare purple/blue
- `Color.healthSuccess` - Success green
- `Color.healthWarning` - Warning orange  
- `Color.healthError` - Error red
- `Spacing` - Consistent spacing values
- `Size` - Standard sizing tokens

#### Basic UI Components
- `HealthButton` - Accessible buttons with healthcare styling
- `PatientAvatar` - Circular avatar with initials
- `StatusIndicator` - Health status with colored indicators

#### Healthcare-Specific Cards
- `GlucoseCard` - Glucose monitoring display with large metrics
- `ProgressCard` - Circular progress ring for tracking metrics
- `NutritionCard` - Nutrition breakdown with macros
- `FoodItemCard` - Individual food item display
- `HeartConditionCard` - Heart monitoring with chart
- `MedicalChartCard` - Complete medical chart with patient info

#### Navigation & Lists
- `MenuListItem` - Menu items with icons and chevrons
- `ProfileHeader` - User profile display
- `KnowledgeCard` - Info cards for tips and guidance
- `WaterIntakeWidget` - Water tracking widget

#### Notifications & Feedback
- `SuccessNotification` - Animated success message with droplets
- `NutritionListItem` - Nutrition tracking list items
- `LineChart` - Simple line chart for health data
- `InfoCard` - Informational cards with actions

### Molecules (Complex Components)

#### Complete Layouts
- `HealthDashboard` - Full dashboard layout combining all components
- `MedicalDashboardPreview` - Curated preview of medical components
- `ComponentShowcase` - Complete design system showcase

## Usage

```swift
import WalnutDesignSystem

// Basic components
HealthButton("Save Reading", style: .primary) {
    // Save action
}

GlucoseCard(
    value: "4.2",
    unit: "mmol/L", 
    status: "Normal",
    timestamp: "5:05 pm"
)

// Complete dashboard
HealthDashboard()
```

## Reference Design Compliance

The components accurately match the provided reference screenshots:

1. **Medical Cards Screen**: Heart condition cards, medical charts, info cards
2. **Nutrition Screen**: Calorie tracking, progress rings, food items
3. **Glucose Monitoring**: Success notifications, line charts, menu items

## Integration

Add to your Tuist project:

```swift
.external(name: "WalnutDesignSystem")
```

## Architecture

```
WalnutDesignSystem/
├── Sources/WalnutDesignSystem/
│   ├── Atoms/           # Basic components
│   ├── Molecules/       # Complex layouts  
│   ├── Preview/         # Showcase and examples
│   └── WalnutDesignSystem.swift
```

## Accessibility

All components include:
- Semantic colors that adapt to light/dark mode
- Minimum 44pt touch targets for buttons
- Proper contrast ratios
- VoiceOver support with descriptive labels
- Dynamic Type support

## Performance

- Lightweight implementation using only native SwiftUI
- Minimal dependencies
- Efficient animations using native SwiftUI modifiers
- Lazy loading for complex layouts

---

Built for Walnut Healthcare App • iOS 17+ • SwiftUI