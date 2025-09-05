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
        
        var stateText: String {
            switch self {
                case .preparing:
                    "Preparing file..."
                case .uploading:
                    "Uploading..."
                case .parsing:
                    "Processing, This may take a while..."
                case .completed:
                    "Complete!"
                case .failed:
                    "Failed"
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
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Medical Case: \(documentType.displayName)")
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .foregroundColor(.primary)
                    .truncationMode(.middle)
                    .multilineTextAlignment(.leading)
                
                Text(customStatusText ?? state.stateText)
                    .font(.system(.caption, design: .rounded, weight: .regular))
                    .foregroundColor(.secondary)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                
                
            }
            
            Spacer()
            
            CombinedPulseView(iconImage: state.iconImage)

        }
        .padding(.horizontal)
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
