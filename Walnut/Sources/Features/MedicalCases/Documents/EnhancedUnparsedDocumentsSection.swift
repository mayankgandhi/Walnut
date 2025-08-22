//
//  EnhancedUnparsedDocumentsSection.swift
//  Walnut
//
//  Created by Mayank Gandhi on 21/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct EnhancedUnparsedDocumentsSection: View {
    let medicalCase: MedicalCase
    @State private var isRetrying = false
    @State private var isExpanded = true
    
    var body: some View {
        HealthCard {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: Spacing.small) {
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.orange)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Failed Documents")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.primary)
                            
                            Text("\(medicalCase.unparsedDocuments.count) documents need attention")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up.circle" : "chevron.down.circle")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 0 : 180))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if isExpanded {
                    LazyVStack(spacing: Spacing.small) {
                        ForEach(medicalCase.unparsedDocuments) { document in
                            EnhancedUnparsedDocumentListItem(
                                document: document,
                                isRetrying: isRetrying,
                                onRetry: { }
                            )
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
    }
}

