import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "music.note.list")
                }

            PresetsView()
                .tabItem {
                    Label("Presets", systemImage: "star")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .tint(Color("AccentAmber"))
    }
}

#Preview {
    ContentView()
        .environment(PresetStore())
        .preferredColorScheme(.dark)
}
