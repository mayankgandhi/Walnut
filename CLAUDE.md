# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Walnut is an iOS healthcare management application built with SwiftUI and SwiftData. It's a medical records management system that allows tracking patients, medical cases, prescriptions, and document parsing using Claude AI.

The workspace contains:
- **Walnut** - Main iOS app target
- **Walnut-Playground** - Development playground/testing target
- **WalnutTests** - Unit tests

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
- **OpenAIDocumentService** (`Sources/Features/DocumentParsing/OpenAIServices/OpenAIDocumentService.swift`) - Handles document parsing via OpenAI API
- Uses GPT-4o with vision model for prescription and lab report parsing
- Supports PDF, image, and text document parsing through base64 encoding
- Implements direct document analysis without file upload/storage

### Key Components
- **ContentView** - App entry point, displays PatientsListView
- **WalnutApp** - Main app with SwiftData model container for Patient
- **ViewComponents/** - Reusable UI components like PDFKitView, StatusIndicator

### Development Notes
- Uses SwiftData for local persistence with automatic model containers
- Implements cascade delete relationships between core entities
- Sample data extensions provided for development and testing
- PostHog dependency for analytics/telemetry
- Bundle ID: m.walnut, team: Q7HVAVTGUP

### Project Configuration
- **Tuist.swift** - Tuist cloud configuration
- **Workspace.swift** - Defines workspace with Walnut and Walnut-Playground projects
- **Walnut/Project.swift** - Main app target configuration with dependencies and settings
- Uses automatic code signing for development team Q7HVAVTGUP