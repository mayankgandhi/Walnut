//
//  TestResultListView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

//
//  TestResultListView.swift
//  Walnut-Playground
//
//  Created by Mayank Gandhi on 30/06/25.
//  Copyright © 2025 m. All rights reserved.
//

import SwiftUI

struct TestResultListView: View {
    
    @State var testResults: [[TestResult]] = dummyTestResults
    
    var body: some View {
        List(testResults, id: \.first?.id) { testResult in
            TestResultChartView(testResults: testResult)
        }
        .listStyle(.plain)
        .navigationTitle(Text("Test Results"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create", systemImage: "plus") {
                    print("Create Button Tapped")
                }
            }
        }
    }
}


struct TestResultListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TestResultListView()
        }
    }
}

