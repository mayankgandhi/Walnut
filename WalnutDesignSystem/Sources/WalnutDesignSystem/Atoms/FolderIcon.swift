//
//  FolderIcon.swift
//  WalnutDesignSystem
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

public struct FolderIcon: View {
    let caseType: MedicalCaseType
    let documentCount: Int
    let size: CGFloat
    
    public init(caseType: MedicalCaseType, documentCount: Int, size: CGFloat = 180) {
        self.caseType = caseType
        self.documentCount = documentCount
        self.size = size
    }
    
    public var body: some View {
        VStack(spacing: size * 0.08) {
            Image(systemName: "folder.fill")
                .font(.system(size: size * 0.6, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [caseType.foregroundColor, caseType.foregroundColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            if documentCount > 0 {
                documentCountIndicator
            }
            
            Text(caseType.shortDisplayName)
                .font(.system(size: size * 0.095, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .opacity(0.75)
        }
        .frame(width: size, height: size)
    }
    
    
    private var documentCountIndicator: some View {
        HStack(spacing: size * 0.02) {
            Image(systemName: "doc.fill")
                .font(.system(size: size * 0.08, weight: .medium))
                .foregroundColor(.secondary)
                .opacity(0.6)
            
            Text("\(documentCount)")
                .font(.system(size: size * 0.09, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
                .opacity(0.8)
        }
        .padding(.horizontal, size * 0.06)
        .padding(.vertical, size * 0.03)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.04))
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - MedicalCaseType Extensions
extension MedicalCaseType {
    var iconName: String {
        switch self {
        case .immunisation:
            return "syringe"
        case .healthCheckup:
            return "heart.text.square"
        case .surgery:
            return "cross.case"
        case .consultation:
            return "stethoscope"
        case .procedure:
            return "medical.thermometer"
        case .followUp:
            return "arrow.clockwise"
        case .treatment:
            return "pills"
        }
    }
    
    var shortDisplayName: String {
        switch self {
        case .immunisation: return "Vacc"
        case .healthCheckup: return "Check"
        case .surgery: return "Surg"
        case .consultation: return "Cons"
        case .procedure: return "Proc"
        case .followUp: return "Follow"
        case .treatment: return "Treat"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
            FolderIcon(caseType: .consultation, documentCount: 3)
            FolderIcon(caseType: .surgery, documentCount: 7)
            FolderIcon(caseType: .healthCheckup, documentCount: 0)
    }
    .padding()
}
