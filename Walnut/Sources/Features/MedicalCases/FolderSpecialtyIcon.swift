//
//  FolderSpecialtyIcon.swift
//  Walnut
//
//  Created by Mayank Gandhi on 30/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

public struct FolderSpecialtyIcon: View {
    
    let specialty: MedicalSpecialty
    let type: MedicalCaseType
    
    public var body: some View {
        // Medical Case Icon
        Image("folder")
            .resizable()
            .scaledToFit()
//            .foregroundStyle(
//                Color.blue.opacity(0.75)
//            )
            .overlay {
                Image(specialty.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60, alignment: .bottom)
                    .offset(x: 18, y: 18)
            }
    }
}

#Preview {
    ScrollView {
        LazyVGrid(
            columns: [.init(), .init(), .init()],
            alignment: .leading,
            spacing: Spacing.xs
        ) {
            ForEach(MedicalSpecialty.allCases, id: \.rawValue) { specialty in
                FolderSpecialtyIcon(specialty: specialty, type: .consultation)
            }
        }
    }
}

#Preview {
    ScrollView {
        LazyVGrid(
            columns: [.init(), .init(), .init()],
            alignment: .leading,
            spacing: Spacing.xs
        ) {
            ForEach(MedicalSpecialty.allCases, id: \.rawValue) { specialty in
                VStack {
                    Image(specialty.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60, alignment: .bottom)
                    Text(specialty.rawValue)
                }
            }
        }
    }
}
