//
//  DocumentFactory.swift
//  Walnut
//
//  Created by Mayank Gandhi on 22/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI
import WalnutDesignSystem

// MARK: - Document Action Protocol

protocol DocumentActionHandler: ObservableObject {
    func handleTap()
    func getContextMenuItems() -> [DocumentContextMenuItem]
    func getNavigationDestination() -> AnyView?
}

// MARK: - Context Menu Item

struct DocumentContextMenuItem {
    let title: String
    let systemImage: String
    let action: () -> Void
    let isDestructive: Bool
    let isDisabled: Bool
    
    init(
        title: String,
        systemImage: String,
        action: @escaping () -> Void,
        isDestructive: Bool = false,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
        self.isDestructive = isDestructive
        self.isDisabled = isDisabled
    }
}

// MARK: - Document Factory

class DocumentFactory {
    
    private let patient: Patient
    
    init(patient: Patient) {
        self.patient = patient
    }
    
    func createActionHandler(for item: DocumentItem) -> any DocumentActionHandler {
        switch item {
        case .prescription(let prescription):
                return PrescriptionActionHandler(
                    patient: patient,
                    prescription: prescription
                )
        case .bloodReport(let bloodReport):
            return BioMarkerReportActionHandler(bloodReport: bloodReport)
        case .document(let document):
            return OtherDocumentActionHandler(document: document)
        }
    }
}

// MARK: - Prescription Action Handler

@Observable
class PrescriptionActionHandler: DocumentActionHandler {
    private let patient: Patient
    private let prescription: Prescription
    
    private var navigationState = NavigationState()
    
    init(patient: Patient, prescription: Prescription) {
        self.patient = patient
        self.prescription = prescription
    }
    
    func handleTap() {
        navigationState.selectedPrescription = prescription
    }
    
    func getContextMenuItems() -> [DocumentContextMenuItem] {
        [
            DocumentContextMenuItem(
                title: "Edit Prescription",
                systemImage: "pencil",
                action: {
                    // TODO: Implement edit functionality
                }
            ),
            DocumentContextMenuItem(
                title: "View Details",
                systemImage: "eye",
                action: {
                    self.navigationState.selectedPrescription = self.prescription
                }
            ),
            DocumentContextMenuItem(
                title: "Share Document",
                systemImage: "square.and.arrow.up",
                action: {
                    self.shareDocument(self.prescription.document)
                },
                isDisabled: prescription.document == nil
            )
        ]
    }
    
    func getNavigationDestination() -> AnyView? {
        if navigationState.selectedPrescription != nil {
            return AnyView(
                PrescriptionDetailView(patient: patient, prescription: prescription)
            )
        }
        return nil
    }
    
    private func shareDocument(_ document: Document?) {
        guard let document = document else { return }
        
        let activityController = UIActivityViewController(
            activityItems: [document.fileURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
}

// MARK: - Blood Report Action Handler

@Observable
class BioMarkerReportActionHandler: DocumentActionHandler {
    private let bloodReport: BioMarkerReport
    private var navigationState = NavigationState()
    
    init(bloodReport: BioMarkerReport) {
        self.bloodReport = bloodReport
    }
    
    func handleTap() {
        navigationState.selectedBioMarkerReport = bloodReport
    }
    
    func getContextMenuItems() -> [DocumentContextMenuItem] {
        [
            DocumentContextMenuItem(
                title: "View Details",
                systemImage: "eye",
                action: {
                    self.navigationState.selectedBioMarkerReport = self.bloodReport
                }
            ),
            DocumentContextMenuItem(
                title: "Export Results",
                systemImage: "square.and.arrow.up",
                action: {
                    // TODO: Implement export functionality
                }
            ),
            DocumentContextMenuItem(
                title: "Share Document",
                systemImage: "square.and.arrow.up",
                action: {
                    self.shareDocument(self.bloodReport.document)
                },
                isDisabled: bloodReport.document == nil
            )
        ]
    }
    
    func getNavigationDestination() -> AnyView? {
        if navigationState.selectedBioMarkerReport != nil {
            return AnyView(
                BioMarkerReportDetailView(bloodReport: bloodReport)
            )
        }
        return nil
    }
    
    private func shareDocument(_ document: Document?) {
        guard let document = document else { return }
        
        let activityController = UIActivityViewController(
            activityItems: [document.fileURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }
}

@Observable
class OtherDocumentActionHandler: DocumentActionHandler {
    
    private let document: Document
    private var navigationState = NavigationState()
    
    init(document: Document) {
        self.document = document
    }
    
    func handleTap() {
        navigationState.selectedDocument = document
    }
    
    func getContextMenuItems() -> [DocumentContextMenuItem] {
        [
            DocumentContextMenuItem(
                title: "View Document",
                systemImage: "eye",
                action: {
                    self.navigationState.selectedDocument = self.document
                }
            ),
            DocumentContextMenuItem(
                title: "Share Document",
                systemImage: "square.and.arrow.up",
                action: {
                    self.shareDocument(self.document)
                }
            ),
            DocumentContextMenuItem(
                title: "Delete Document",
                systemImage: "trash",
                action: {
                    // TODO: Implement delete functionality
                },
                isDestructive: true
            )
        ]
    }
    
    func getNavigationDestination() -> AnyView? {
        if navigationState.selectedDocument != nil {
            return AnyView(
                DocumentViewer(document: document)
            )
        }
        return nil
    }
    
    private func shareDocument(_ document: Document) {
        let activityController = UIActivityViewController(
            activityItems: [document.fileURL],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityController, animated: true)
        }
    }

}


// MARK: - Navigation State

@Observable
class NavigationState {
    var selectedPrescription: Prescription?
    var selectedBioMarkerReport: BioMarkerReport?
    var selectedDocument: Document?
}


// MARK: - SwiftUI Extensions for Context Menu

extension View {
    
    func documentContextMenu(items: [DocumentContextMenuItem]) -> some View {
        self.contextMenu {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Button(action: item.action) {
                    Label(item.title, systemImage: item.systemImage)
                }
                .disabled(item.isDisabled)
                
                if item.isDestructive {
                    Divider()
                }
            }
        }
    }
}
