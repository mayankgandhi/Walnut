//
//  BioMarkerResultEditor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import SwiftData
import WalnutDesignSystem

struct BioMarkerResultEditor: View {
    
    let bloodTestResult: BioMarkerResult?
    let onSave: (BioMarkerResult) -> Void
    
    init(bloodTestResult: BioMarkerResult? = nil, onSave: @escaping (BioMarkerResult) -> Void) {
        self.bloodTestResult = bloodTestResult
        self.onSave = onSave
    }
    
    private var editorTitle: String {
        bloodTestResult == nil ? "Add Test Result" : "Edit Test Result"
    }
    
    @State private var testName = ""
    @State private var value = ""
    @State private var unit = ""
    @State private var referenceRange = ""
    @State private var isAbnormal = false
    
    @Environment(\.dismiss) private var dismiss
    
    // Focus management for keyboard navigation
    @FocusState private var focusedField: FormField?
    
    private enum FormField: Hashable, CaseIterable {
        case testName
        case value
        case unit
        case referenceRange
        
        private enum NextFieldType {
            case textField(FormField)
            case nonTextFieldOrEnd
        }
        
        private var nextFieldInUI: NextFieldType {
            switch self {
            case .testName:
                return .textField(.value)
            case .value:
                return .textField(.unit)
            case .unit:
                return .textField(.referenceRange)
            case .referenceRange:
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
        !testName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !unit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !referenceRange.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Focus navigation helpers
    private func focusNextField(after currentField: FormField) {
        if currentField.shouldDismissKeyboard {
            if currentField == .referenceRange && isFormValid {
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
                    // Test Result Information Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Test Result Information")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        VStack(spacing: Spacing.medium) {
                            TextFieldItem(
                                icon: "testtube.2",
                                title: "Test Name",
                                text: $testName,
                                placeholder: "Enter test name",
                                iconColor: .healthPrimary,
                                isRequired: true,
                                contentType: .none,
                                submitLabel: FormField.testName.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .testName)
                                }
                            )
                            .focused($focusedField, equals: .testName)
                            
                            TextFieldItem(
                                icon: "chart.bar.fill",
                                title: "Value",
                                text: $value,
                                placeholder: "Enter test value",
                                helperText: "The numeric or text result",
                                iconColor: .blue,
                                isRequired: true,
                                contentType: .none,
                                submitLabel: FormField.value.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .value)
                                }
                            )
                            .focused($focusedField, equals: .value)
                            
                            TextFieldItem(
                                icon: "ruler.fill",
                                title: "Unit",
                                text: $unit,
                                placeholder: "e.g., mg/dL, g/L, %",
                                helperText: "Unit of measurement",
                                iconColor: .orange,
                                isRequired: true,
                                contentType: .none,
                                submitLabel: FormField.unit.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .unit)
                                }
                            )
                            .focused($focusedField, equals: .unit)
                            
                            TextFieldItem(
                                icon: "arrow.left.and.right",
                                title: "Reference Range",
                                text: $referenceRange,
                                placeholder: "e.g., 4.5-5.5, <200, >10",
                                helperText: "Normal range for this test",
                                iconColor: .green,
                                isRequired: true,
                                contentType: .none,
                                submitLabel: FormField.referenceRange.appropriateSubmitLabel,
                                onSubmit: {
                                    focusNextField(after: .referenceRange)
                                }
                            )
                            .focused($focusedField, equals: .referenceRange)
                        }
                    }
                    
                    // Result Status Section
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Result Status")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, Spacing.medium)
                        
                        ToggleItem(
                            icon: isAbnormal ? "exclamationmark.triangle.fill" : "checkmark.circle.fill",
                            title: "Abnormal Result",
                            subtitle: "Mark if result is outside normal range",
                            isOn: $isAbnormal,
                            helperText: "Toggle if this result requires attention",
                            iconColor: isAbnormal ? .healthError : .healthSuccess
                        )
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
                if let bloodTestResult {
                    loadBioMarkerResultData(bloodTestResult)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
    
    private func loadBioMarkerResultData(_ bloodTestResult: BioMarkerResult) {
        testName = bloodTestResult.testName ?? ""
        value = bloodTestResult.value ?? ""
        unit = bloodTestResult.unit ?? ""
        referenceRange = bloodTestResult.referenceRange ?? ""
        isAbnormal = bloodTestResult.isAbnormal ?? false
    }
    
    private func save() {
        if let bloodTestResult {
            // Edit existing test result - update properties but don't perform modelContext operations
            bloodTestResult.testName = testName.trimmingCharacters(in: .whitespacesAndNewlines)
            bloodTestResult.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
            bloodTestResult.unit = unit.trimmingCharacters(in: .whitespacesAndNewlines)
            bloodTestResult.referenceRange = referenceRange.trimmingCharacters(in: .whitespacesAndNewlines)
            bloodTestResult.isAbnormal = isAbnormal
            
            onSave(bloodTestResult)
        } else {
            // Create new test result - just pass data to parent, no modelContext operations
            let newBioMarkerResult = BioMarkerResult(
                id: UUID(),
                testName: testName.trimmingCharacters(in: .whitespacesAndNewlines),
                value: value.trimmingCharacters(in: .whitespacesAndNewlines),
                unit: unit.trimmingCharacters(in: .whitespacesAndNewlines),
                referenceRange: referenceRange.trimmingCharacters(in: .whitespacesAndNewlines),
                isAbnormal: isAbnormal,
                bloodReport: nil
            )
            
            onSave(newBioMarkerResult)
        }
    }
}

// MARK: - Previews

#Preview("Add Test Result") {
    BioMarkerResultEditor(bloodTestResult: nil) { _ in }
        .modelContainer(for: BioMarkerResult.self, inMemory: true)
}

