//
//  CloudKitSyncMonitor.swift
//  Walnut
//
//  Created by Mayank Gandhi on 08/06/25.
//  Copyright © 2025 m. All rights reserved.
//


//
//  CloudKitSyncMonitor.swift
//  Cashew
//
//  Created by Mayank Gandhi on 07/05/25.
//  Copyright © 2025 m. All rights reserved.
//

import Combine
import CoreData

class CloudKitSyncMonitor: ObservableObject {
    @Published var syncStatus: SyncStatus = .idle

    enum SyncStatus {
        case idle, syncing, error(Error)
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
            .sink { [weak self] notification in
                guard let self = self else { return }
                guard let cloudEvent = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else { return }

                switch cloudEvent.type {
                case .setup:
                    self.updateStatus(for: cloudEvent)
                case .import:
                    self.updateStatus(for: cloudEvent)
                case .export:
                    self.updateStatus(for: cloudEvent)
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func updateStatus(for event: NSPersistentCloudKitContainer.Event) {
        DispatchQueue.main.async {
            if event.endDate == nil {
                self.syncStatus = .syncing
            } else if let error = event.error {
                self.syncStatus = .error(error)
            } else {
                self.syncStatus = .idle
            }
        }
    }
}
