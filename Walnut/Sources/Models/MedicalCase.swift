//
//  MedicalCaseDummyData.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

struct MedicalCaseData: Hashable, Identifiable {
    let id: UUID
    let title: String
    let notes: String
    let treatmentPlan: String
    let type: MedicalCaseType // immunisation, health-checkup, surgery, follow-up, treatment, diagnosis
    let specialty: MedicalSpecialty // Cardiologist, Endocrinologist, etc.
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    
    static let sampleCases: [MedicalCaseData] = [
        // Cardiology Cases
        MedicalCaseData(
            id: UUID(),
            title: "Hypertension Management",
            notes: "Patient presents with elevated blood pressure readings over the past 3 months. Family history of cardiovascular disease. Currently experiencing mild headaches and occasional dizziness. Diagnosed with Stage 1 hypertension. Started on ACE inhibitor therapy with good response. Regular follow-ups show gradual improvement.",
            treatmentPlan: "1. Start ACE inhibitor (Lisinopril 10mg daily)\n2. Dietary modifications - reduce sodium intake\n3. Regular exercise 30min/day\n4. Weight management\n5. Follow-up in 4 weeks",
            type: .consultation,
            specialty: .cardiologist,
            isActive: true,
            createdAt: Date().addingTimeInterval(-2_592_000), // 30 days ago
            updatedAt: Date().addingTimeInterval(-86_400), // 1 day ago
        ),
        
        // Endocrinology Cases
        MedicalCaseData(
            id: UUID(),
            title: "Type 2 Diabetes Management",
            notes: "Initial diagnosis following elevated HbA1c (8.2%) and fasting glucose (156 mg/dL). Patient reports increased thirst, frequent urination, and fatigue over past 2 months. BMI: 32.4. Started on Metformin with diabetes education. Ongoing monitoring and treatment adjustments as needed.",
            treatmentPlan: "1. Metformin 500mg twice daily\n2. Diabetes education class enrollment\n3. Blood glucose monitoring kit\n4. Dietary consultation with nutritionist\n5. HbA1c recheck in 3 months\n6. Ophthalmology referral for diabetic eye exam",
            type: .consultation,
            specialty: .endocrinologist,
            isActive: false,
            createdAt: Date().addingTimeInterval(-1_296_000), // 15 days ago
            updatedAt: Date().addingTimeInterval(-43_200), // 12 hours ago
        ),
        
        
        
       
        // Health Check-up
        MedicalCaseData(
            id: UUID(),
            title: "Annual Physical Exam",
            notes: "Routine annual physical for 45-year-old male. Overall good health. Mild elevation in cholesterol levels. No acute complaints. Last colonoscopy 3 years ago.",
            treatmentPlan: "1. Continue current exercise routine\n2. Dietary modifications for cholesterol\n3. Lipid panel recheck in 6 months\n4. Schedule colonoscopy (due)\n5. Flu vaccination administered\n6. Next annual exam in 12 months",
            type: .healthCheckup,
            specialty: .generalPractitioner,
            isActive: false,
            createdAt: Date().addingTimeInterval(-172_800), // 2 days ago
            updatedAt: Date().addingTimeInterval(-7_200), // 2 hours ago
        ),
       
       
        
        // Surgery - Ophthalmology
        MedicalCaseData(
            id: UUID(),
            title: "Cataract Surgery - Right Eye",
            notes: "Progressive visual impairment in right eye due to mature cataract. Visual acuity 20/80 in affected eye. Patient reports difficulty with night driving and reading. No other ocular pathology noted.",
            treatmentPlan: "1. Pre-operative clearance obtained\n2. Phacoemulsification with IOL implantation scheduled\n3. Post-operative antibiotic and steroid drops\n4. Follow-up appointments at 1 day, 1 week, and 1 month\n5. Second eye evaluation in 6 months",
            type: .surgery,
            specialty: .ophthalmologist,
            isActive: false,
            createdAt: Date().addingTimeInterval(-1_728_000), // 20 days ago
            updatedAt: Date().addingTimeInterval(-14_400), // 4 hours ago
        ),
        
        // Dermatology Surgery
        MedicalCaseData(
            id: UUID(),
            title: "Skin Lesion Excision",
            notes: "Suspicious pigmented lesion on upper back noted during skin screening. Dermoscopy shows irregular borders and color variation. Biopsy recommended to rule out melanoma.",
            treatmentPlan: "1. Excisional biopsy with 2mm margins\n2. Send specimen for histopathological examination\n3. Wound care instructions provided\n4. Suture removal in 10-14 days\n5. Results discussion appointment scheduled\n6. Further treatment based on pathology results",
            type: .surgery,
            specialty: .dermatologist,
            isActive: false,
            createdAt: Date().addingTimeInterval(-518_400), // 6 days ago
            updatedAt: Date().addingTimeInterval(-28_800), // 8 hours ago
        ),
        
        // Neurology
        MedicalCaseData(
            id: UUID(),
            title: "Chronic Migraine Management",
            notes: "Patient diagnosed with chronic migraine 18 months ago, presenting with 15+ headache days per month. Initial treatment with basic preventive medications showed partial response. Recent escalation in frequency and severity prompted treatment intensification. Comprehensive migraine management plan implemented including lifestyle modifications and advanced preventive therapies.",
            treatmentPlan: "1. Increase topiramate to 100mg daily\n2. Add CGRP inhibitor (erenumab) injection\n3. Headache diary continuation\n4. Trigger identification and avoidance\n5. Stress management techniques\n6. Follow-up in 6 weeks",
            type: .consultation,
            specialty: .neurologist,
            isActive: false,
            createdAt: Date().addingTimeInterval(-1_036_800), // 12 days ago
            updatedAt: Date().addingTimeInterval(-7_200), // 2 hours ago
        )
    ]

}

// MARK: - Extension for easy access
extension MedicalCaseData {
    static func randomCase() -> MedicalCaseData {
        return sampleCases.randomElement()!
    }
    
    static func recentCases(days: Int = 30) -> [MedicalCaseData] {
        let cutoffDate = Date().addingTimeInterval(-TimeInterval(days * 24 * 60 * 60))
        return sampleCases.filter { $0.createdAt >= cutoffDate }
    }

    static func activeCases() -> [MedicalCaseData] {
        return sampleCases.filter { $0.isActive }
    }
}


extension Array where Element == MedicalCaseData {
    func groupCasesBySpecialty() -> [MedicalSpecialty: [MedicalCaseData]] {
        let grouped = Dictionary(grouping: self, by: { $0.specialty })
        
        return grouped.mapValues { casesInSpecialty in
            casesInSpecialty.sorted { $0.createdAt > $1.createdAt }
        }
    }
}
