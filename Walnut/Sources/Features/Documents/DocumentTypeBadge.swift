//
//  DocumentTypeBadge.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 02/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

// MARK: - Document Type Badge
struct DocumentTypeBadge: View {
    
    let documentType: DocumentType
    
    // Preferred initializer using enum
    init(documentType: DocumentType) {
        self.documentType = documentType
    }
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: documentType.typeIcon)
                .font(.system(size: 8))
            
            Text(documentType.displayName)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(documentType.backgroundColor)
        .foregroundColor(.white)
        .cornerRadius(6)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 8) {
        ForEach(DocumentType.allCases, id: \.hashValue) {
            DocumentTypeBadge(documentType: $0)
        }
    }
    .padding()
}
