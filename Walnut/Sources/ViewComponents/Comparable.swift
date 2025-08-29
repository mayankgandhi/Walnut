//
//  Comparable.swift
//  Walnut
//
//  Created by Mayank Gandhi on 28/08/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

extension Optional: @retroactive Comparable where Wrapped: Comparable {
    public static func < (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Bool {
        switch (lhs, rhs) {
        case (nil, nil): return false
        case (nil, _): return true
        case (_, nil): return false
        case let (left?, right?): return left < right
        }
    }
}

