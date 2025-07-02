//
//  TestResult.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//


import Foundation

// MARK: - TestResult Structure
struct TestResult: Identifiable, Codable, Hashable {
    let id: UUID
    let createdAt: Date
    let updatedAt: Date
    let resultDate: Date
    let markerCode: String
    let markerName: String
    let numericValue: Double
    let unit: String
    let value: String // String representation for display
    let notes: String?
    
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        resultDate: Date,
        markerCode: String,
        markerName: String,
        numericValue: Double,
        unit: String,
        notes: String? = nil
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.resultDate = resultDate
        self.markerCode = markerCode
        self.markerName = markerName
        self.numericValue = numericValue
        self.unit = unit
        self.value = "\(numericValue) \(unit)"
        self.notes = notes
        
    }
}


// MARK: - Sample TestResults Dataset
let dummyTestResults: [[TestResult]] = [
    
    // HbA1c Results (over 12 months)
    [
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
            markerCode: "HBA1C",
            markerName: "Hemoglobin A1c",
            numericValue: 8.2,
            unit: "%",
            notes: "Baseline reading - diabetes management needed"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -9, to: Date())!,
            markerCode: "HBA1C",
            markerName: "Hemoglobin A1c",
            numericValue: 7.8,
            unit: "%",
            notes: "Slight improvement with medication"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            markerCode: "HBA1C",
            markerName: "Hemoglobin A1c",
            numericValue: 7.1,
            unit: "%",
            notes: "Good progress with diet changes"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            markerCode: "HBA1C",
            markerName: "Hemoglobin A1c",
            numericValue: 6.8,
            unit: "%",
            notes: "Approaching target range"
        ),
        TestResult(
            resultDate: Date(),
            markerCode: "HBA1C",
            markerName: "Hemoglobin A1c",
            numericValue: 6.4,
            unit: "%",
            notes: "Excellent control achieved"
        )
    ],
    
    // Sodium Levels (monthly over 6 months)
    [
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            markerCode: "NA",
            markerName: "Sodium",
            numericValue: 142,
            unit: "mmol/L",
            notes: "Normal range"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -5, to: Date())!,
            markerCode: "NA",
            markerName: "Sodium",
            numericValue: 139,
            unit: "mmol/L"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
            markerCode: "NA",
            markerName: "Sodium",
            numericValue: 145,
            unit: "mmol/L",
            notes: "Slightly elevated"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            markerCode: "NA",
            markerName: "Sodium",
            numericValue: 141,
            unit: "mmol/L"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -2, to: Date())!,
            markerCode: "NA",
            markerName: "Sodium",
            numericValue: 138,
            unit: "mmol/L"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
            markerCode: "NA",
            markerName: "Sodium",
            numericValue: 143,
            unit: "mmol/L"
        )
    ],
    
    // Cholesterol Total (quarterly over 2 years)
    [
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -24, to: Date())!,
            markerCode: "CHOL",
            markerName: "Total Cholesterol",
            numericValue: 285,
            unit: "mg/dL",
            notes: "High - lifestyle changes recommended"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -21, to: Date())!,
            markerCode: "CHOL",
            markerName: "Total Cholesterol",
            numericValue: 268,
            unit: "mg/dL",
            notes: "Improving with diet"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -18, to: Date())!,
            markerCode: "CHOL",
            markerName: "Total Cholesterol",
            numericValue: 245,
            unit: "mg/dL"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -15, to: Date())!,
            markerCode: "CHOL",
            markerName: "Total Cholesterol",
            numericValue: 223,
            unit: "mg/dL",
            notes: "Medication started"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
            markerCode: "CHOL",
            markerName: "Total Cholesterol",
            numericValue: 198,
            unit: "mg/dL",
            notes: "Good response to treatment"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -9, to: Date())!,
            markerCode: "CHOL",
            markerName: "Total Cholesterol",
            numericValue: 185,
            unit: "mg/dL"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            markerCode: "CHOL",
            markerName: "Total Cholesterol",
            numericValue: 192,
            unit: "mg/dL"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            markerCode: "CHOL",
            markerName: "Total Cholesterol",
            numericValue: 178,
            unit: "mg/dL",
            notes: "Target achieved"
        )
    ],
    
    // Blood Pressure Systolic (weekly over 2 months)
    [
        TestResult(
            resultDate: Calendar.current.date(byAdding: .weekOfYear, value: -8, to: Date())!,
            markerCode: "SBP",
            markerName: "Systolic Blood Pressure",
            numericValue: 155,
            unit: "mmHg",
            notes: "Hypertensive reading"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .weekOfYear, value: -7, to: Date())!,
            markerCode: "SBP",
            markerName: "Systolic Blood Pressure",
            numericValue: 148,
            unit: "mmHg"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .weekOfYear, value: -6, to: Date())!,
            markerCode: "SBP",
            markerName: "Systolic Blood Pressure",
            numericValue: 142,
            unit: "mmHg",
            notes: "Medication adjustment"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .weekOfYear, value: -5, to: Date())!,
            markerCode: "SBP",
            markerName: "Systolic Blood Pressure",
            numericValue: 138,
            unit: "mmHg"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date())!,
            markerCode: "SBP",
            markerName: "Systolic Blood Pressure",
            numericValue: 135,
            unit: "mmHg"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!,
            markerCode: "SBP",
            markerName: "Systolic Blood Pressure",
            numericValue: 128,
            unit: "mmHg",
            notes: "Approaching normal"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date())!,
            markerCode: "SBP",
            markerName: "Systolic Blood Pressure",
            numericValue: 132,
            unit: "mmHg"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!,
            markerCode: "SBP",
            markerName: "Systolic Blood Pressure",
            numericValue: 125,
            unit: "mmHg",
            notes: "Normal range achieved"
        )
    ],
    
    // Vitamin D (semi-annual over 3 years)
    [
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -36, to: Date())!,
            markerCode: "VIT_D",
            markerName: "Vitamin D (25-OH)",
            numericValue: 18.5,
            unit: "ng/mL",
            notes: "Deficient - supplementation needed"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -30, to: Date())!,
            markerCode: "VIT_D",
            markerName: "Vitamin D (25-OH)",
            numericValue: 25.2,
            unit: "ng/mL",
            notes: "Improving with supplements"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -24, to: Date())!,
            markerCode: "VIT_D",
            markerName: "Vitamin D (25-OH)",
            numericValue: 32.8,
            unit: "ng/mL",
            notes: "Sufficient level reached"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -18, to: Date())!,
            markerCode: "VIT_D",
            markerName: "Vitamin D (25-OH)",
            numericValue: 28.9,
            unit: "ng/mL"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
            markerCode: "VIT_D",
            markerName: "Vitamin D (25-OH)",
            numericValue: 35.1,
            unit: "ng/mL",
            notes: "Good maintenance level"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            markerCode: "VIT_D",
            markerName: "Vitamin D (25-OH)",
            numericValue: 31.7,
            unit: "ng/mL"
        )
    ],
    
    // Thyroid TSH (quarterly)
    [
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -12, to: Date())!,
            markerCode: "TSH",
            markerName: "Thyroid Stimulating Hormone",
            numericValue: 8.2,
            unit: "mIU/L",
            notes: "Elevated - possible hypothyroidism"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -9, to: Date())!,
            markerCode: "TSH",
            markerName: "Thyroid Stimulating Hormone",
            numericValue: 6.8,
            unit: "mIU/L",
            notes: "Levothyroxine started"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -6, to: Date())!,
            markerCode: "TSH",
            markerName: "Thyroid Stimulating Hormone",
            numericValue: 4.2,
            unit: "mIU/L",
            notes: "Improving"
        ),
        TestResult(
            resultDate: Calendar.current.date(byAdding: .month, value: -3, to: Date())!,
            markerCode: "TSH",
            markerName: "Thyroid Stimulating Hormone",
            numericValue: 2.8,
            unit: "mIU/L",
            notes: "Within normal range"
        ),
        TestResult(
            resultDate: Date(),
            markerCode: "TSH",
            markerName: "Thyroid Stimulating Hormone",
            numericValue: 2.1,
            unit: "mIU/L",
            notes: "Optimal level"
        )
    ]
]

// MARK: - Helper Extension for Data Access
extension Array where Element == [TestResult] {
    subscript(markerCode: String) -> [TestResult]? {
        return self.first { results in
            results.first?.markerCode == markerCode
        }
    }
    
    var allMarkerCodes: [String] {
        return self.compactMap { $0.first?.markerCode }
    }
    
    var allMarkerNames: [String] {
        return self.compactMap { $0.first?.markerName }
    }
}

// MARK: - Usage Examples
/*
 // Access HbA1c results
 let hba1cResults = dummyTestResults["HBA1C"]
 
 // Get all available marker codes
 let markers = dummyTestResults.allMarkerCodes
 print("Available markers: \(markers)")
 
 // Access by index
 let sodiumResults = dummyTestResults[1] // Sodium levels
 let cholesterolResults = dummyTestResults[2] // Cholesterol levels
 */


// MARK: - Sample Data
extension TestResult {
    
    static let dummyTestResults: [TestResult] = [
        // Diabetes Markers
        TestResult(
            resultDate: Date(),
            markerCode: "HBA1C",
            markerName: "Hemoglobin A1c",
            numericValue: 6.8,
            unit: "%",
            notes: "Slightly elevated, recommend dietary consultation"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "GLU_FAST",
            markerName: "Fasting Glucose",
            numericValue: 105,
            unit: "mg/dL",
            notes: "Within normal range"
        ),
        
        // Complete Blood Count
        TestResult(
            resultDate: Date(),
            markerCode: "HGB",
            markerName: "Hemoglobin",
            numericValue: 14.2,
            unit: "g/dL",
            notes: "Normal levels"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "HCT",
            markerName: "Hematocrit",
            numericValue: 42.5,
            unit: "%"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "WBC",
            markerName: "White Blood Cell Count",
            numericValue: 7.2,
            unit: "K/uL"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "RBC",
            markerName: "Red Blood Cell Count",
            numericValue: 4.8,
            unit: "M/uL"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "PLT",
            markerName: "Platelet Count",
            numericValue: 285,
            unit: "K/uL"
        ),
        
        // Lipid Panel
        TestResult(
            resultDate: Date(),
            markerCode: "CHOL_TOT",
            markerName: "Total Cholesterol",
            numericValue: 195,
            unit: "mg/dL",
            notes: "Desirable level"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "HDL",
            markerName: "HDL Cholesterol",
            numericValue: 58,
            unit: "mg/dL",
            notes: "Good level"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "LDL",
            markerName: "LDL Cholesterol",
            numericValue: 115,
            unit: "mg/dL",
            notes: "Near optimal"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "TRIG",
            markerName: "Triglycerides",
            numericValue: 142,
            unit: "mg/dL"
        ),
        
        // Liver Function
        TestResult(
            resultDate: Date(),
            markerCode: "ALT",
            markerName: "Alanine Aminotransferase",
            numericValue: 28,
            unit: "U/L",
            notes: "Normal liver function"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "AST",
            markerName: "Aspartate Aminotransferase",
            numericValue: 32,
            unit: "U/L"
        ),
        
        // Kidney Function
        TestResult(
            resultDate: Date(),
            markerCode: "CREAT",
            markerName: "Creatinine",
            numericValue: 1.1,
            unit: "mg/dL",
            notes: "Normal kidney function"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "BUN",
            markerName: "Blood Urea Nitrogen",
            numericValue: 18,
            unit: "mg/dL"
        ),
        
        // Thyroid Function
        TestResult(
            resultDate: Date(),
            markerCode: "TSH",
            markerName: "Thyroid Stimulating Hormone",
            numericValue: 2.4,
            unit: "mIU/L",
            notes: "Normal thyroid function"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "T4_FREE",
            markerName: "Free Thyroxine",
            numericValue: 1.3,
            unit: "ng/dL"
        ),
        
        // Electrolytes
        TestResult(
            resultDate: Date(),
            markerCode: "NA",
            markerName: "Sodium",
            numericValue: 140,
            unit: "mmol/L"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "K",
            markerName: "Potassium",
            numericValue: 4.2,
            unit: "mmol/L"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "CL",
            markerName: "Chloride",
            numericValue: 102,
            unit: "mmol/L"
        ),
        
        // Vitamins
        TestResult(
            resultDate: Date(),
            markerCode: "VIT_D",
            markerName: "Vitamin D, 25-Hydroxy",
            numericValue: 32,
            unit: "ng/mL",
            notes: "Adequate level"
        ),
        
        TestResult(
            resultDate: Date(),
            markerCode: "VIT_B12",
            markerName: "Vitamin B12",
            numericValue: 485,
            unit: "pg/mL",
            notes: "Normal level"
        )
    ]
}

// MARK: - Convenience Methods
extension TestResult {
    /// Returns a formatted string for display
    var displayValue: String {
        return "\(numericValue) \(unit)"
    }
    
    /// Checks if the result is within normal range (simplified logic)
    func isNormal() -> Bool {
        switch markerCode {
        case "HBA1C":
            return numericValue < 5.7
        case "GLU_FAST":
            return numericValue >= 70 && numericValue <= 100
        case "HGB":
            return numericValue >= 12.0 && numericValue <= 16.0
        case "CHOL_TOT":
            return numericValue < 200
        case "HDL":
            return numericValue >= 40
        case "LDL":
            return numericValue < 100
        default:
            return true // Default to normal for unknown markers
        }
    }
    
    /// Returns the status as a string
    var status: String {
        return isNormal() ? "Normal" : "Abnormal"
    }
}
