//
//  UploadViewBottomAccessory.swift
//  Walnut
//
//  Created by Mayank Gandhi on 04/09/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

struct UploadViewBottomAccessory: View {
    
    enum UploadViewBottomAccessoryState {
        case preparing
        case uploading
        case parsing
        case completed
        case failed
        
        var iconImage: String {
            switch self {
                case .preparing:
                    "upload-icon"
                case .uploading:
                    "upload-icon"
                case .parsing:
                    "document-scan"
                case .completed:
                    "checked"
                case .failed:
                    "document-failed"
            }
        }
        
        func stateText(documentName: String) -> String {
            switch self {
                case .preparing:
                    "Preparing \(documentName) doc..."
                case .uploading:
                    "Uploading \(documentName) doc..."
                case .parsing:
                    "Processing \(documentName) doc..."
                case .completed:
                    "Completed!"
                case .failed:
                    "Failed parsing \(documentName)..."
            }
        }
    }
    
    let documentType: DocumentType
    let state: UploadViewBottomAccessoryState
    let progress: Double
    let customStatusText: String?
    
    init(
        documentType: DocumentType,
        state: UploadViewBottomAccessoryState,
        progress: Double = 0.0,
        customStatusText: String? = nil
    ) {
        self.documentType = documentType
        self.state = state
        self.progress = progress
        self.customStatusText = customStatusText
    }
    
    var body: some View {
        HStack {
            Image(documentType.iconImage)
                .resizable()
                .frame(width: 48, height: 48, alignment: .center)
            
            Text(state.stateText(documentName: documentType.displayName))
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundColor(.primary)
                .truncationMode(.middle)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
            
            Spacer()
            
            CombinedPulseView(iconImage: state.iconImage)
        }
        .padding(.horizontal, Spacing.medium)
    }
}



#Preview {
    
    TabView {
        Tab("Account", systemImage: "person.2.badge.gearshape.fill") {
            Text(verbatim: "")
        }
    }
    .tabViewBottomAccessory {
        UploadViewBottomAccessory(
            documentType: .imaging,
            state: .uploading,
            progress: 0.3
        )
    }
}

#Preview {
    
    TabView {
        Tab("Account", systemImage: "person.2.badge.gearshape.fill") {
            Text(verbatim: "")
        }
    }
    .tabViewBottomAccessory {
        UploadViewBottomAccessory(
            documentType: .imaging,
            state: .parsing,
            progress: 0.7
        )
    }
}


#Preview {
    
    TabView {
        Tab("Account", systemImage: "person.2.badge.gearshape.fill") {
            Text(verbatim: "")
        }
    }
    .tabViewBottomAccessory {
        UploadViewBottomAccessory(
            documentType: .imaging,
            state: .completed
        )
    }
}


#Preview {
    
    TabView {
        Tab("Account", systemImage: "person.2.badge.gearshape.fill") {
            Text(verbatim: "")
        }
    }
    .tabViewBottomAccessory {
        UploadViewBottomAccessory(
            documentType: .imaging,
            state: .failed
        )
    }
}
