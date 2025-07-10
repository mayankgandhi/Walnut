//
//  DocumentParsingViewCoordinator.swift
//  Walnut
//
//  Created by Mayank Gandhi on 10/07/25.
//  Copyright © 2025 m. All rights reserved.
//

import Combine
import Foundation

class DocumentParsingViewCoordinator {
        
    static var shared: DocumentParsingViewCoordinator = DocumentParsingViewCoordinator()
    
    let fileUploadSubject = PassthroughSubject<(MedicalCase, URL), Never>()
    
    private init() { }
    
}
