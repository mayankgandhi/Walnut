
import SwiftUI
import ComposableArchitecture

public struct ContentView: View {
    
    public init() {}
    static let store = Store(initialState: PatientHomeFeature.State(), reducer: {
        PatientHomeFeature()
    })

    public var body: some View {
        PatientHomeView(store: ContentView.store)
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
