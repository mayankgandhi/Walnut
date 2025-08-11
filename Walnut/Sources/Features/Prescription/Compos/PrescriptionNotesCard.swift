//
//  PrescriptionNotesCard.swift
//  Walnut
//
//  Created by Mayank Gandhi on 03/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct PrescriptionNotesCard: View {
    let notes: String
    
    init?(prescription: Prescription) {
        guard let notes = prescription.notes, !notes.isEmpty else {
            return nil
        }
        self.notes = notes
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "note.text")
                    .font(.title2)
                    .foregroundColor(.indigo)
                
                Text("Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            Text(notes)
                .font(.subheadline)
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

