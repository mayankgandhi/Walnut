//
//  Patient+MedicalCasesView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 29/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct MedicalCasesView: View {
    
    let medicalCases: [String: [MedicalCaseData]]
    
    init(medicalCases: [MedicalCaseData]) {
        self.medicalCases = medicalCases.groupCasesBySpecialty()
    }
    
    var body: some View {
        List {
            ForEach(medicalCases.keys.sorted(), id: \.self) { specialty in
                Section(header: Text(specialty)) {
                    ForEach(medicalCases[specialty] ?? []) { medicalCase in
                        MedicalCaseListItem(medicalCase: medicalCase)
                    }
                }
            }
        }
        .navigationTitle("Medical Cases")
    }
    
}

#Preview {
    MedicalCasesView(medicalCases: MedicalCaseData.sampleCases)
}

extension Array where Element == MedicalCaseData {
    func groupCasesBySpecialty() -> [String: [MedicalCaseData]] {
        let grouped = Dictionary(grouping: self, by: { $0.specialty })
        
        return grouped.mapValues { casesInSpecialty in
            casesInSpecialty.sorted { $0.createdAt > $1.createdAt }
        }
    }
}
