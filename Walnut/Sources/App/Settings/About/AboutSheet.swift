//
//  AboutSheet.swift
//  Walnut
//
//  Created by Mayank Gandhi on 26/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import WalnutDesignSystem
import SwiftUI

struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: Spacing.large) {
                
                VStack(spacing: Spacing.medium) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.healthPrimary)
                    
                    Text("Walnut")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Personal Health Tracker")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HealthCard {
                    VStack(spacing: Spacing.medium) {
                        HStack {
                            Text("Version")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(appVersion)
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Build")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(buildNumber)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(Spacing.medium)
            .navigationTitle(Text("About").font(.system(.largeTitle, design: .rounded)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AboutSheet()
}
