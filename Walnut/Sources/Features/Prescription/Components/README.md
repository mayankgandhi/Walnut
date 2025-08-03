# Prescription Components

This directory contains modularized SwiftUI components for the prescription detail view, following modern iOS development patterns and enhancing code maintainability.

## Components Overview

### Core Cards
- **PrescriptionHeaderCard** - Displays doctor information, facility details, and prescription metadata
- **PrescriptionMedicationsCard** - Container for medications list with enhanced styling
- **PrescriptionFollowUpCard** - Shows follow-up appointments and required tests
- **PrescriptionNotesCard** - Displays prescription notes with proper formatting
- **PrescriptionDocumentCard** - Document attachment display with type-aware styling

### Medication Components
- **MedicationDetailCard** - Comprehensive individual medication display with schedule and instructions
- **MedicationScheduleChip** - Reusable component for medication timing (premium and compact styles)

### Document Viewing
- **DocumentViewerSheet** - Full-screen document viewer supporting:
  - PDF documents via PDFKit
  - Image documents (JPEG, PNG, HEIC, HEIF)
  - Error handling for unsupported formats
  - Share functionality

## Architecture Benefits

- **Performance**: Reduced main view from 626 to 71 lines
- **Maintainability**: Single responsibility principle for each component
- **Reusability**: Components can be used across different prescription views
- **Modern SwiftUI**: iOS 18 patterns, LazyVStack, material backgrounds
- **Type Safety**: Clean data interfaces with proper error handling

## Usage Example

```swift
// Main view composition
LazyVStack(spacing: 20) {
    PrescriptionHeaderCard(prescription: prescription)
    
    if !prescription.medications.isEmpty {
        PrescriptionMedicationsCard(medications: prescription.medications)
    }
    
    if let notesCard = PrescriptionNotesCard(prescription: prescription) {
        notesCard
    }
    
    if let documentCard = PrescriptionDocumentCard(prescription: prescription, onViewDocument: handleDocumentView) {
        documentCard
    }
}
```

## Component Features

### Document Viewing
- **Type Detection**: Automatically detects file type from extension
- **Appropriate Icons**: Different icons and colors for PDFs, images, and unknown types
- **Full-Screen Viewing**: Immersive document viewing experience
- **Share Integration**: Native iOS sharing functionality
- **Error Handling**: Graceful handling of missing or corrupt files

### Medication Display
- **Enhanced Design**: Premium styling with gradients and material backgrounds
- **Schedule Visualization**: Clear display of medication timing and dosage
- **Conditional Rendering**: Smart hiding of empty sections
- **Accessibility**: Proper typography and semantic structure