# WalnutDesignSystem - CLAUDE.md

## Overview

WalnutDesignSystem is a comprehensive design system framework for the Walnut healthcare management iOS application. It provides consistent, reusable UI components following healthcare-specific design patterns and accessibility standards.

## Architecture

The design system follows atomic design principles:

### Atoms (`Sources/WalnutDesignSystem/Atoms/`)
Basic building blocks and fundamental UI elements:
- **DSButton.swift** - Standard button components
- **DSCard.swift** - Knowledge base card with title, subtitle, and icon
- **DSItemCard.swift** - Item display cards
- **DSListItem.swift** - List item components
- **HealthCard.swift** - Healthcare-specific card wrapper with `PatientAvatar` component
- **HealthIndicators.swift** - Health status indicators (`StatusIndicator`, `HealthMetric`, `HealthStatus` enum)
- **InputFieldItems.swift** - Form input components
- **TextFieldItem.swift** - Text input fields
- **ColorPickerItem.swift** - Color selection components
- **MenuListItem.swift** - Menu navigation items
- **SuccessNotification.swift** - Success state notifications

### Molecules (`Sources/WalnutDesignSystem/Molecules/`)
Composite components combining atoms:
- **BioMarkerInfoView.swift** - Biomarker information display
- **BiomarkerInfo.swift** - Biomarker data presentation
- **BiomarkerListItemView.swift** - List items for biomarkers
- **HealthDashboard1.swift** - Dashboard layout component
- **MetricView.swift** - Health metric display components

### Organisms (`Sources/WalnutDesignSystem/Organisms/`)
Complex UI patterns and layouts:
- **BiomarkerDetailView.swift** - Detailed biomarker views
- **LineChart.swift** - Data visualization charts

### Theme (`Sources/WalnutDesignSystem/Theme/`)
Design tokens and styling constants:

#### Colors.swift
- **Healthcare Brand Colors**: `healthPrimary`, `healthSuccess`, `healthWarning`, `healthError`
- **Health-Specific Semantic Colors**: `heartRate`, `glucose`, `medication`, `labResults`
- **Automatic light/dark mode support**

#### Spacing.swift
- **Spacing Constants**: `xs` (4pt), `small` (8pt), `medium` (16pt), `large` (24pt), `xl` (32pt)
- **Size Constants**: Touch targets and avatar sizes
- **View Extensions**: `cardStyle()`, `subtleCardStyle()`, `touchTarget()`

#### Typography.swift
- **Health-Specific Fonts**: `healthMetricLarge`, `healthMetricMedium`, `healthMetricSmall`
- **Text Style Modifiers**: `healthMetricPrimary()`, `healthMetricSecondary()`, `successStyle()`, `errorStyle()`, `warningStyle()`

## Integration Guide

### 1. Import the Framework
```swift
import WalnutDesignSystem
```

### 2. Use Design System Components

#### Basic Cards
```swift
// Simple health card wrapper
HealthCard {
    VStack {
        Text("Patient Info")
        // Your content
    }
}

// Knowledge base card
DSCard(
    title: "Got a question?",
    subtitle: "Ask our AI assistant",
    imageName: "questionmark.circle",
    backgroundColor: .healthPrimary
)
```

#### Patient Avatar
```swift
PatientAvatar(
    initials: "JD",
    color: .healthPrimary,
    size: Size.avatarLarge
)
```

#### Health Indicators
```swift
// Status indicator
StatusIndicator(status: .good)

// Health metric display
HealthMetric(
    value: "120/80",
    unit: "mmHg",
    label: "Blood Pressure",
    status: .good
)
```

### 3. Use Design System Tokens

#### Spacing
```swift
VStack(spacing: Spacing.medium) {
    // Content with consistent spacing
}
.padding(Spacing.large)
```

#### Colors
```swift
Text("Success Message")
    .foregroundColor(.healthSuccess)

Rectangle()
    .fill(.healthPrimary)
```

#### Typography
```swift
Text("120/80")
    .font(.healthMetricLarge)

Text("Blood Pressure")
    .healthMetricSecondary()
```

#### Card Styling
```swift
VStack {
    // Your content
}
.cardStyle() // Applies consistent card styling with materials

// Or for subtle styling
.subtleCardStyle()
```

## Best Practices

### 1. Always Use Design System First
- Check existing atoms/molecules before creating custom components
- Use design system colors, spacing, and typography constants
- Leverage pre-built health indicators and metrics

### 2. Follow Healthcare Patterns
- Use semantic colors (`healthSuccess`, `healthError`, `healthWarning`)
- Apply appropriate health-specific fonts for metrics
- Include status indicators where relevant

### 3. Maintain Consistency
- Use `Spacing` constants instead of hardcoded values
- Apply `cardStyle()` for consistent card appearances
- Follow the atomic design hierarchy when building components

### 4. Accessibility
- All components include proper accessibility labels
- Touch targets meet iOS HIG requirements (`Size.touchTarget`)
- Colors maintain proper contrast ratios

## Available Components Quick Reference

| Component | Type | Usage |
|-----------|------|-------|
| `HealthCard` | Atom | Wrapper for healthcare content with material styling |
| `PatientAvatar` | Atom | Patient initials in colored circle |
| `StatusIndicator` | Atom | Health status with icon/dot and color |
| `HealthMetric` | Atom | Health value display with unit and status |
| `DSCard` | Atom | Knowledge base style card with gradient background |
| `BiomarkerDetailView` | Organism | Complex biomarker information display |
| `LineChart` | Organism | Data visualization for health metrics |

## Color Palette

| Color | Usage | Light Mode | Dark Mode |
|-------|-------|------------|-----------|
| `healthPrimary` | Primary brand, buttons, links | Blue (#6B73FF) | Light Blue (#858DFF) |
| `healthSuccess` | Success states, positive metrics | Green (#00C896) | Light Green (#00E0B0) |
| `healthWarning` | Warning states, attention needed | Orange (#FFB800) | Light Orange (#FFD14D) |
| `healthError` | Error states, critical values | Red (#FF5757) | Light Red (#FF7070) |

## Migration from Custom Components

When updating existing components to use the design system:

1. Replace hardcoded spacing with `Spacing` constants
2. Replace custom colors with design system colors
3. Replace custom cards with `HealthCard` wrapper
4. Replace custom avatars with `PatientAvatar`
5. Replace status displays with `StatusIndicator`
6. Use health-specific typography for metrics
7. Apply `cardStyle()` for consistent appearance

Example migration:
```swift
// Before
VStack(spacing: 16) {
    Text("Patient Name")
        .font(.system(size: 24, weight: .bold))
}
.padding(20)
.background(Color.blue.opacity(0.1))
.cornerRadius(12)

// After
HealthCard {
    VStack(spacing: Spacing.medium) {
        Text("Patient Name")
            .font(.healthMetricMedium)
    }
}
```