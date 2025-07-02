//
//  Workspace.swift
//  Manifests
//
//  Created by Mayank Gandhi on 07/06/25.
//

@preconcurrency import ProjectDescription

let workspace = Workspace(
    name: "WalnutApp",
    projects: [
        "Walnut",
        "Walnut-Playground"
    ]
)
