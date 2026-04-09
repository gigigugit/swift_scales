import SwiftUI

@main
struct SwiftScalesApp: App {
    @State private var presetStore = PresetStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(presetStore)
                .preferredColorScheme(.dark)
        }
    }
}
