//
//  PatientDeleteButton.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - View
struct PatientDeleteButton: View {
    
    @Bindable var store: StoreOf<PatientDeleteFeature>
    
    var body: some View {
        VStack(spacing: 24) {
            // Visual separator
            Rectangle()
                .fill(Color.gray)
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            Button {
                store.send(.deleteButtonTapped)
            } label: {
                HStack(spacing: 12) {
                    if store.isDeleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text(store.isDeleting ? "Deleting..." : "Delete Patient")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(store.isDeleting ? Color.secondary : Color.red)
                        .shadow(
                            color: Color.gray.opacity(0.15),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                )
            }
            .disabled(store.isDeleting)
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            
            // Warning text
            Text("This action cannot be undone. All patient data including medical records and lab results will be permanently deleted.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 20)
        .alert(
            "Delete Patient",
            isPresented: $store.isShowingDeleteAlert
        ) {
            Button("Cancel", role: .cancel) {
                store.send(.deleteAlertDismissed)
            }
            Button("Delete", role: .destructive) {
                store.send(.deleteConfirmed)
            }
        } message: {
            Text("Are you sure you want to delete \(store.patient.fullName)? This action cannot be undone and will permanently delete all associated medical records and lab results.")
        }
    }
}

