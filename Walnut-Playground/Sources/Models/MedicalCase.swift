//
//  MedicalCaseDummyData.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

struct MedicalCaseData: Identifiable {
    let id: UUID
    let title: String
    let notes: String
    let treatmentPlan: String
    let type: String // immunisation, health-checkup, surgery, follow-up, treatment, diagnosis
    let specialty: String // Cardiologist, Endocrinologist, etc.
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
            type: "consultation",
            specialty: "Cardiologist",
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
            type: "consultation",
            specialty: "Endocrinologist",
            isActive: true,
            createdAt: Date().addingTimeInterval(-1_296_000), // 15 days ago
            updatedAt: Date().addingTimeInterval(-43_200), // 12 hours ago
        ),
        
        // General Practice Cases
        MedicalCaseData(
            id: UUID(),
            title: "Acute Bronchitis",
            notes: "Patient presents with productive cough, chest congestion, and low-grade fever (100.8°F) for 5 days. No shortness of breath. Chest X-ray clear. Recent upper respiratory infection 2 weeks ago. Diagnosed with acute bronchitis, treated conservatively. Recovery expected within 10 days.",
            treatmentPlan: "1. Supportive care with rest and fluids\n2. Dextromethorphan for cough suppression\n3. Guaifenesin for mucus thinning\n4. Return if symptoms worsen or persist >10 days\n5. No antibiotics indicated at this time",
            type: "consultation",
            specialty: "General Practitioner",
            isActive: false,
            createdAt: Date().addingTimeInterval(-604_800), // 7 days ago
            updatedAt: Date().addingTimeInterval(-259_200), // 3 days ago
        ),
        
        // Orthopedic Cases
        MedicalCaseData(
            id: UUID(),
            title: "Chronic Lower Back Pain",
            notes: "6-month history of lower back pain radiating to left leg. MRI shows mild disc herniation at L4-L5. Pain scale 6/10, worse with sitting and bending forward. Previous PT showed minimal improvement. Ongoing pain management with regular follow-ups and treatment adjustments.",
            treatmentPlan: "1. Continue current NSAID regimen\n2. Referral to pain management specialist\n3. Consider epidural steroid injection\n4. Physical therapy reassessment\n5. Ergonomic workplace evaluation\n6. Weight loss counseling",
            type: "consultation",
            specialty: "Orthopedic Surgeon",
            isActive: true,
            createdAt: Date().addingTimeInterval(-5_184_000), // 60 days ago
            updatedAt: Date().addingTimeInterval(-172_800), // 2 days ago
        ),
        
        // Health Check-up
        MedicalCaseData(
            id: UUID(),
            title: "Annual Physical Exam",
            notes: "Routine annual physical for 45-year-old male. Overall good health. Mild elevation in cholesterol levels. No acute complaints. Last colonoscopy 3 years ago.",
            treatmentPlan: "1. Continue current exercise routine\n2. Dietary modifications for cholesterol\n3. Lipid panel recheck in 6 months\n4. Schedule colonoscopy (due)\n5. Flu vaccination administered\n6. Next annual exam in 12 months",
            type: "health-checkup",
            specialty: "General Practitioner",
            isActive: true,
            createdAt: Date().addingTimeInterval(-172_800), // 2 days ago
            updatedAt: Date().addingTimeInterval(-7_200), // 2 hours ago
        ),
        
        // Psychiatry Cases
        MedicalCaseData(
            id: UUID(),
            title: "Generalized Anxiety Disorder Management",
            notes: "Initial diagnosis of generalized anxiety disorder 6 months ago. Patient presented with excessive worry, restlessness, and sleep disturbances. Started on SSRI therapy with cognitive behavioral therapy. Recent follow-up shows improvement with current treatment. Sleep quality has improved. Panic episodes reduced from daily to 2-3 times per week.",
            treatmentPlan: "1. Continue sertraline 50mg daily\n2. Continue cognitive behavioral therapy sessions\n3. Stress management techniques\n4. Regular exercise recommendations\n5. Follow-up in 6 weeks\n6. Consider dosage adjustment if needed",
            type: "consultation",
            specialty: "Psychiatrist",
            isActive: true,
            createdAt: Date().addingTimeInterval(-3_888_000), // 45 days ago
            updatedAt: Date().addingTimeInterval(-21_600), // 6 hours ago
        ),
        
        // Immunization
        MedicalCaseData(
            id: UUID(),
            title: "COVID-19 Booster Vaccination",
            notes: "Patient due for COVID-19 booster shot. Last vaccination was 8 months ago. No adverse reactions to previous vaccines. Currently healthy with no contraindications.",
            treatmentPlan: "1. Administer COVID-19 booster (mRNA vaccine)\n2. Observe for 15 minutes post-vaccination\n3. Provide vaccination card update\n4. Schedule next booster as recommended\n5. Advise on common side effects",
            type: "immunisation",
            specialty: "General Practitioner",
            isActive: true,
            createdAt: Date().addingTimeInterval(-86_400), // 1 day ago
            updatedAt: Date().addingTimeInterval(-3_600), // 1 hour ago
        ),
        
        // Surgery - Ophthalmology
        MedicalCaseData(
            id: UUID(),
            title: "Cataract Surgery - Right Eye",
            notes: "Progressive visual impairment in right eye due to mature cataract. Visual acuity 20/80 in affected eye. Patient reports difficulty with night driving and reading. No other ocular pathology noted.",
            treatmentPlan: "1. Pre-operative clearance obtained\n2. Phacoemulsification with IOL implantation scheduled\n3. Post-operative antibiotic and steroid drops\n4. Follow-up appointments at 1 day, 1 week, and 1 month\n5. Second eye evaluation in 6 months",
            type: "surgery",
            specialty: "Ophthalmologist",
            isActive: true,
            createdAt: Date().addingTimeInterval(-1_728_000), // 20 days ago
            updatedAt: Date().addingTimeInterval(-14_400), // 4 hours ago
        ),
        
        // Oncology
        MedicalCaseData(
            id: UUID(),
            title: "Breast Cancer Treatment and Surveillance",
            notes: "Stage II breast cancer diagnosed 12 months ago. Patient underwent lumpectomy followed by adjuvant chemotherapy and radiation therapy. Treatment completed 6 months ago. Currently on hormonal therapy with tamoxifen. Post-treatment surveillance ongoing with regular monitoring. Recent mammography and tumor markers within normal limits. Patient doing well with no concerning symptoms.",
            treatmentPlan: "1. Continue quarterly oncology visits\n2. Annual mammography scheduled\n3. Continue tamoxifen therapy\n4. Monitor for recurrence symptoms\n5. Psychological support as needed\n6. Next follow-up in 3 months",
            type: "consultation",
            specialty: "Oncologist",
            isActive: true,
            createdAt: Date().addingTimeInterval(-7_776_000), // 90 days ago
            updatedAt: Date().addingTimeInterval(-432_000), // 5 days ago
        ),
        
        // Pediatric Immunization
        MedicalCaseData(
            id: UUID(),
            title: "Routine Pediatric Vaccinations",
            notes: "6-month-old infant presenting for routine vaccinations. Growth and development appropriate for age. No acute illness. Parents have questions about vaccine schedule and side effects.",
            treatmentPlan: "1. Administer DTaP, IPV, Hib, PCV13, and Rotavirus vaccines\n2. Provide vaccine information sheets\n3. Discuss common side effects and fever management\n4. Schedule 9-month wellness visit\n5. Address parental concerns about vaccines",
            type: "immunisation",
            specialty: "Pediatrician",
            isActive: true,
            createdAt: Date().addingTimeInterval(-259_200), // 3 days ago
            updatedAt: Date().addingTimeInterval(-10_800), // 3 hours ago
        ),
        
        // Dermatology Surgery
        MedicalCaseData(
            id: UUID(),
            title: "Skin Lesion Excision",
            notes: "Suspicious pigmented lesion on upper back noted during skin screening. Dermoscopy shows irregular borders and color variation. Biopsy recommended to rule out melanoma.",
            treatmentPlan: "1. Excisional biopsy with 2mm margins\n2. Send specimen for histopathological examination\n3. Wound care instructions provided\n4. Suture removal in 10-14 days\n5. Results discussion appointment scheduled\n6. Further treatment based on pathology results",
            type: "surgery",
            specialty: "Dermatologist",
            isActive: true,
            createdAt: Date().addingTimeInterval(-518_400), // 6 days ago
            updatedAt: Date().addingTimeInterval(-28_800), // 8 hours ago
        ),
        
        // Neurology
        MedicalCaseData(
            id: UUID(),
            title: "Chronic Migraine Management",
            notes: "Patient diagnosed with chronic migraine 18 months ago, presenting with 15+ headache days per month. Initial treatment with basic preventive medications showed partial response. Recent escalation in frequency and severity prompted treatment intensification. Comprehensive migraine management plan implemented including lifestyle modifications and advanced preventive therapies.",
            treatmentPlan: "1. Increase topiramate to 100mg daily\n2. Add CGRP inhibitor (erenumab) injection\n3. Headache diary continuation\n4. Trigger identification and avoidance\n5. Stress management techniques\n6. Follow-up in 6 weeks",
            type: "consultation",
            specialty: "Neurologist",
            isActive: true,
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
    
    static func casesByType(_ type: String) -> [MedicalCaseData] {
        return sampleCases.filter { $0.type == type }
    }
    
    static func casesBySpecialty(_ specialty: String) -> [MedicalCaseData] {
        return sampleCases.filter { $0.specialty == specialty }
    }
    
    static func activeCases() -> [MedicalCaseData] {
        return sampleCases.filter { $0.isActive }
    }
}

