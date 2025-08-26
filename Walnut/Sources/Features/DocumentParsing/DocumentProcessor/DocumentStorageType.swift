//
//  DocumentStorageType.swift
//  Walnut
//
//  Created by Mayank Gandhi on 25/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

enum DocumentStorageType {
    case prescription
    case bloodReport
    case otherDocuments
    case unparsed
    
    var folderName: String {
        switch self {
        case .prescription:
            return "Prescriptions"
        case .bloodReport:
            return "BloodReports"
        case .unparsed:
            return "UnparsedDocuments"
        case .otherDocuments:
            return "OtherDocuments"
        }
    }
}
