//
//  BloodReportEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct BloodReportEditor: View {
    
    let bloodReport: BloodReport?
    let medicalCase: MedicalCase
    
    init(bloodReport: BloodReport? = nil, medicalCase: MedicalCase) {
        self.bloodReport = bloodReport
        self.medicalCase = medicalCase
    }
    
    private var editorTitle: String {
        bloodReport == nil ? "Add Blood Report" : "Edit Blood Report"
    }
    
    @State private var testName = ""
    @State private var labName = ""
    @State private var category = ""
    @State private var resultDate = Date()
    @State private var notes = ""
    @State private var testResults: [BloodTestResult] = []
    
    // Blood test result editor sheet states
    @State private var showTestResultEditor = false
    @State private var testResultToEdit: BloodTestResult? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Focus management for keyboard navigation
    @FocusState private var focusedField: FormField?
    
    private enum FormField: Hashable, CaseIterable {
        case testName
        case labName
        case category
        case notes
        
        private enum NextFieldType {
            case textField(FormField)
            case nonTextFieldOrEnd
        }
        
        private var nextFieldInUI: NextFieldType {
            switch self {
            case .testName:
                return .textField(.labName)
            case .labName:
                return .textField(.category)
            case .category:
                return .nonTextFieldOrEnd  // Next: Date picker
            case .notes:
                return .nonTextFieldOrEnd  // Last field
            }
        }
        
        var shouldDismissKeyboard: Bool {
            switch nextFieldInUI {
            case .nonTextFieldOrEnd:
                return true
            case .textField:
                return false
            }
        }
        
        var nextTextField: FormField? {
            switch nextFieldInUI {
            case .textField(let field):
                return field
            case .nonTextFieldOrEnd:
                return nil
            }
        }
        
        var appropriateSubmitLabel: SubmitLabel {
            return shouldDismissKeyboard ? .done : .next
        }
    }
    
    private var isFormValid: Bool {
        !testName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !labName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Focus navigation helpers
    private func focusNextField(after currentField: FormField) {
        if currentField.shouldDismissKeyboard {
            if currentField == .notes && isFormValid {
                submitForm()
            } else {
                focusedField = nil
            }
        } else if let nextField = currentField.nextTextField {
            focusedField = nextField
        } else {
            focusedField = nil
        }
    }
    
    private func submitForm() {
        withAnimation(.easeInOut(duration: 0.3)) {
            save()
            dismiss()
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Spacing.large) {
                    // Blood Report Information Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        
                        Text("Blood Report Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)

                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "heart.text.square.fill",
                                title: "Test Name",
                                text: $testName,
                                placeholder: "Enter test name",
                                iconColor: .healthPrimary,
                                contentType: .none,
                                submitLabel: FormField.testName.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .testName)
                                }
                            )
                            .focused($focusedField, equals: .testName)
                            
                            TextFieldItem(
                                icon: "building.2.fill",
                                title: "Laboratory Name",
                                text: $labName,
                                placeholder: "Enter laboratory name",
                                iconColor: .blue,
                                contentType: .organizationName,
                                submitLabel: FormField.labName.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .labName)
                                }
                            )
                            .focused($focusedField, equals: .labName)
                            
                            TextFieldItem(
                                icon: "folder.fill",
                                title: "Category",
                                text: $category,
                                placeholder: "e.g., Hematology, Chemistry, Immunology",
                                helperText: "Test category or panel type",
                                iconColor: .purple,
                                contentType: .none,
                                submitLabel: FormField.category.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .category)
                                }
                            )
                            .focused($focusedField, equals: .category)
                            
                            DatePickerItem(
                                icon: "calendar",
                                title: "Result Date",
                                selectedDate: Binding(
                                    get: { resultDate },
                                    set: { resultDate = $0 ?? Date() }
                                ),
                                helperText: "When the test results were issued",
                                iconColor: .green,
                                isRequired: false
                            )
                        }
                    }
                    
                    // Medical Case Information Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Medical Case")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        HealthCard {
                            HStack(spacing: Spacing.medium) {
                                
                                OptionalView(medicalCase.specialty) { specialty in
                                    Circle()
                                        .fill(specialty.color.opacity(0.15))
                                        .frame(width: Size.avatarLarge, height: Size.avatarLarge)
                                        .overlay {
                                            Image(systemName: specialty.icon)
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundStyle(specialty.color)
                                        }
                                }
                                
                                VStack(alignment: .leading, spacing: Spacing.small) {
                                    
                                    OptionalView(medicalCase.title) { title in
                                        Text(title)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                    }
                                    
                                    OptionalView(medicalCase.specialty) { specialty in
                                        Text(specialty.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    OptionalView(medicalCase.isActive) { isActive in
                                        HStack(spacing: Spacing.small) {
                                            HealthStatusIndicator(
                                                status: isActive ? .good : .warning,
                                                showIcon: false
                                            )
                                            
                                            Text(isActive ? "Active" : "Inactive")
                                                .font(.caption2.weight(.medium))
                                                .foregroundStyle(isActive ? Color.healthSuccess : Color.healthWarning)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    // Additional Information Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        Text("Additional Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        TextFieldItem(
                            icon: "note.text",
                            title: "Report Notes",
                            text: $notes,
                            placeholder: "Additional notes about the blood report",
                            helperText: "Any additional report details or observations",
                            iconColor: .gray,
                            submitLabel: FormField.notes.appropriateSubmitLabel,
                            onSubmit: {
                                focusNextField(after: .notes)
                            }
                        )
                        .focused($focusedField, equals: .notes)
                    }
                    
                    // Test Results Section
                    VStack(alignment: .leading, spacing: Spacing.small) {
                        HStack {
                            Text("Test Results")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button {
                                testResultToEdit = nil
                                showTestResultEditor = true
                            } label: {
                                HStack(spacing: Spacing.small) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Add")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .foregroundStyle(Color.healthPrimary)
                            }
                        }
                        .padding(.horizontal, Spacing.medium)
                        
                        if testResults.isEmpty {
                            HealthCard {
                                VStack(spacing: Spacing.medium) {
                                    Circle()
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(width: Size.avatarLarge, height: Size.avatarLarge)
                                        .overlay {
                                            Image(systemName: "testtube.2")
                                                .font(.system(size: 24, weight: .semibold))
                                                .foregroundStyle(.secondary)
                                        }
                                    
                                    VStack(spacing: Spacing.small) {
                                        Text("No Test Results Added")
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(.primary)
                                        
                                        Text("Tap the Add button to add individual test results to this blood report")
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Spacing.medium)
                            }
                        } else {
                            VStack(spacing: Spacing.medium) {
                                ForEach(testResults) { testResult in
                                    testResultListItem(testResult: testResult)
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: Spacing.xl)
                }
                .padding(.horizontal, Spacing.medium)
                .padding(.top, Spacing.medium)
            }
            .navigationTitle(editorTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        submitForm()
                    }
                    .disabled(!isFormValid)
                    .font(.system(size: 16, weight: .semibold))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                }
            }
            .onAppear {
                if let bloodReport {
                    loadBloodReportData(bloodReport)
                }
            }
            .sheet(isPresented: $showTestResultEditor) {
                if let testResultToEdit = testResultToEdit {
                    BloodTestResultEditor(
                        bloodTestResult: testResultToEdit,
                        onSave: handleTestResultSave
                    )
                } else {
                    BloodTestResultEditor(
                        bloodTestResult: nil,
                        onSave: handleTestResultSave
                    )
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    @ViewBuilder
    private func testResultListItem(testResult: BloodTestResult) -> some View {
        HealthCard {
            HStack(spacing: Spacing.medium) {
                // Test result icon
                Circle()
                    .fill(testResult.isAbnormal == true ? Color.healthError.opacity(0.15) : Color.healthSuccess.opacity(0.15))
                    .frame(width: Size.avatarMedium, height: Size.avatarMedium)
                    .overlay {
                        Image(systemName: testResult.isAbnormal == true ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(testResult.isAbnormal == true ? Color.healthError : Color.healthSuccess)
                    }
                
                // Test result details
                VStack(alignment: .leading, spacing: Spacing.small) {
                    OptionalView(testResult.testName) { name in
                        Text(name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    
                    HStack(spacing: Spacing.small) {
                        if let value = testResult.value {
                            Text(value)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.primary)
                        }
                        
                        if testResult.value != nil && testResult.unit != nil {
                            Text(testResult.unit!)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if testResult.value != nil && testResult.referenceRange != nil {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        
                        if let referenceRange = testResult.referenceRange {
                            Text("Ref: \(referenceRange)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Status badge
                    if let isAbnormal = testResult.isAbnormal {
                        HStack(spacing: Spacing.small) {
                            Text(isAbnormal ? "Abnormal" : "Normal")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(isAbnormal ? Color.healthError : Color.healthSuccess)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    (isAbnormal ? Color.healthError : Color.healthSuccess).opacity(0.1),
                                    in: Capsule()
                                )
                        }
                    }
                }
                
                Spacer()
                
                // Edit button
                Button {
                    testResultToEdit = testResult
                    showTestResultEditor = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.healthPrimary)
                }
                .buttonStyle(.borderless)
            }
        }
    }
    
    private func handleTestResultSave(_ testResult: BloodTestResult) {
        if let index = testResults.firstIndex(where: { $0.id == testResult.id }) {
            // Update existing test result
            testResults[index] = testResult
        } else {
            // Add new test result
            testResults.append(testResult)
        }
    }
    
    private func loadBloodReportData(_ bloodReport: BloodReport) {
        testName = bloodReport.testName ?? ""
        labName = bloodReport.labName ?? ""
        category = bloodReport.category ?? ""
        if let resultDate = bloodReport.resultDate {
            self.resultDate = resultDate
        }
        notes = bloodReport.notes ?? ""
        testResults = bloodReport.testResults ?? []
    }
    
    private func save() {
        let now = Date()
        
        if let bloodReport {
            // Edit existing blood report
            bloodReport.testName = testName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : testName.trimmingCharacters(in: .whitespacesAndNewlines)
            bloodReport.labName = labName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : labName.trimmingCharacters(in: .whitespacesAndNewlines)
            bloodReport.category = category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : category.trimmingCharacters(in: .whitespacesAndNewlines)
            bloodReport.resultDate = resultDate
            bloodReport.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
            bloodReport.testResults = testResults
            bloodReport.updatedAt = now
        } else {
            // Create new blood report
            let newBloodReport = BloodReport(
                id: UUID(),
                testName: testName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : testName.trimmingCharacters(in: .whitespacesAndNewlines),
                labName: labName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : labName.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : category.trimmingCharacters(in: .whitespacesAndNewlines),
                resultDate: resultDate,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines),
                createdAt: now,
                updatedAt: now,
                medicalCase: medicalCase,
                document: nil,
                testResults: testResults
            )
            
            // Set bloodReport relationship for all test results
            for testResult in testResults {
                testResult.bloodReport = newBloodReport
            }
            
            modelContext.insert(newBloodReport)
        }
    }
}

#Preview("Add Blood Report") {
    BloodReportEditor(bloodReport: nil, medicalCase: .sampleCase)
        .modelContainer(for: BloodReport.self, inMemory: true)
}

#Preview("Edit Blood Report") {
    let sampleBloodReport = BloodReport(
        id: UUID(),
        testName: "Complete Blood Count",
        labName: "LabCorp",
        category: "Hematology",
        resultDate: Date().addingTimeInterval(-86400 * 2),
        notes: "All values within normal range",
        createdAt: Date(),
        updatedAt: Date(),
        medicalCase: .sampleCase,
        document: nil,
        testResults: []
    )
    
    BloodReportEditor(bloodReport: sampleBloodReport, medicalCase: .sampleCase)
        .modelContainer(for: BloodReport.self, inMemory: true)
}
