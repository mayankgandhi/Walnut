# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Walnut is an iOS healthcare management application built with SwiftUI and SwiftData. It's a medical records management system that allows tracking patients, medical cases, prescriptions, and document parsing using Claude AI.

The workspace contains:
- **Walnut** - Main iOS app target
- **Walnut-Playground** - Development playground/testing target  
- **WalnutTests** - Unit tests
- **AIKit** - AI services framework for document parsing (Claude AI and OpenAI integration)
- **WalnutDesignSystem** - Design system framework with reusable UI components

## Architecture & Code Structure

### Core Data Models (SwiftData)
- **Patient** (`Sources/Models/Patient.swift`) - Core patient entity with demographics and relationships
- **MedicalCase** (`Sources/Models/MedicalCase/MedicalCase.swift`) - Medical cases/visits linked to patients
- **Prescription** (`Sources/Models/Document/Prescription.swift`) - Prescription documents and medications
- **Document** (`Sources/Models/Document/Document.swift`) - General document storage

Key relationships:
- Patient → [MedicalCase] (one-to-many, cascade delete)
- MedicalCase → [Prescription] (one-to-many, cascade delete)

### Feature Architecture
The app follows a feature-based architecture under `Sources/Features/`:

- **PatientList/** - Patient management views and CRUD operations
- **MedicalCases/** - Medical case tracking, editors, and detail views  
- **DocumentParsing/** - OpenAI integration for parsing medical documents
- **Documents/** - Document viewing and management
- **TestResults/** - Lab results and charts

### AI Integration
- **AIKit Framework** (`AIKit/Sources/AIKit/`) - Unified AI services framework
  - **UnifiedDocumentParsingService** - Main service handling both Claude AI and OpenAI document parsing
  - **ClaudeServices** - Claude AI integration with file upload and processing capabilities
  - **OpenAI** - OpenAI GPT models integration for document analysis
  - **Core** - Base networking clients, protocols, and shared models
- Uses both Claude AI (primary) and OpenAI GPT-4o with vision for document parsing
- Supports PDF, image, and text document parsing with flexible routing between services
- Implements direct document analysis with file upload support for Claude AI

### Key Components
- **ContentView** - App entry point, displays PatientsListView
- **WalnutApp** - Main app with SwiftData model container for Patient
- **ViewComponents/** - Reusable UI components like PDFKitView, StatusIndicator
- **WalnutDesignSystem** - Design system framework with atoms, molecules, and organisms
  - **Atoms** - Basic UI components (DSButton, DSCard, HealthCard, PatientAvatar, StatusIndicator, HealthMetric, InputFieldItems, etc.)
  - **Molecules** - Composite components (BioMarkerInfoView, MetricView, etc.)
  - **Organisms** - Complex UI patterns (BiomarkerDetailView, LineChart, etc.)
  - **Theme** - Colors (.healthPrimary, .healthSuccess, .healthError), Spacing (Spacing.medium, Spacing.large), Typography (.healthMetricLarge)
  
  **Integration Guidelines:**
  - Always import `WalnutDesignSystem` when working with UI components
  - Use `HealthCard` wrapper for consistent card styling instead of custom backgrounds
  - Replace hardcoded spacing with design system constants (Spacing.xs, .small, .medium, .large, .xl)
  - Use health-specific colors (.healthPrimary, .healthSuccess, .healthWarning, .healthError)
  - Apply health typography for metrics (.healthMetricLarge, .healthMetricMedium, .healthMetricSmall)
  - Use `PatientAvatar` for patient initials instead of custom circles
  - Use `StatusIndicator` and `HealthMetric` for health data display
  - Apply `.cardStyle()` modifier for consistent card appearance

### Development Notes
- Uses SwiftData for local persistence with automatic model containers
- Implements cascade delete relationships between core entities
- Sample data extensions provided for development and testing
- PostHog dependency for analytics/telemetry
- Bundle ID: m.walnut, team: Q7HVAVTGUP
- Modular architecture with separate frameworks (AIKit, WalnutDesignSystem)
- Tuist-based project generation and workspace management

### Project Configuration
- **Tuist.swift** - Tuist cloud configuration
- **Workspace.swift** - Defines workspace with Walnut, Walnut-Playground, AIKit, and WalnutDesignSystem projects
- **Walnut/Project.swift** - Main app target configuration with dependencies and settings
- **AIKit/Project.swift** - AI services framework configuration
- **WalnutDesignSystem/Project.swift** - Design system framework configuration  
- Uses automatic code signing for development team Q7HVAVTGUP