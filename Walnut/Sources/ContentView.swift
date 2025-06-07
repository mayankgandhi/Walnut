
import SwiftUI
import ComposableArchitecture

public struct ContentView: View {
    public init() {}

    public var body: some View {
        AddPatientView(
            store: Store(initialState: AddPatientFeature.State()) {
                AddPatientFeature()
            }
        )
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
