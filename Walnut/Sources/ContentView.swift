
import SwiftUI
import ComposableArchitecture

public struct ContentView: View {
    
    public init() {}

    public var body: some View {
        PatientHomeView(store: Store(initialState: PatientHomeFeature.State(), reducer: {
            PatientHomeFeature()
        }))
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
