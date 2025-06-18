//
//  PatientView.swift
//  Walnut
//
//  Created by Mayank Gandhi on 19/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

// MARK: - Patient Home View
struct PatientView: View {
    @Bindable var store: StoreOf<PatientReducer>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                PatientHeaderView(patient: store.patient)
                PatientDeleteButton(store: store.scope(state: \.delete, action: \.delete))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }
}



