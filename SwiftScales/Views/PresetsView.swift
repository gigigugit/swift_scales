import SwiftUI

struct PresetsView: View {
    @Environment(PresetStore.self) private var presetStore
    @State private var showAddPreset = false
    @State private var newPresetViewModel = FretboardViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if presetStore.presets.isEmpty {
                    ContentUnavailableView(
                        "No Presets",
                        systemImage: "star.slash",
                        description: Text("Save a configuration from the Explore tab.")
                    )
                    .foregroundStyle(Color("AccentAmber"))
                } else {
                    List {
                        ForEach(presetStore.presets) { preset in
                            PresetRow(preset: preset)
                                .listRowBackground(Color("FretboardBackground"))
                        }
                        .onDelete(perform: presetStore.delete)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color("AppBackground"))
                }
            }
            .background(Color("AppBackground"))
            .navigationTitle("Presets")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddPreset = true }) {
                        Image(systemName: "plus")
                    }
                    .tint(Color("AccentAmber"))
                }
            }
        }
        .sheet(isPresented: $showAddPreset) {
            SavePresetSheet(vm: newPresetViewModel)
        }
    }
}

private struct PresetRow: View {
    let preset: Preset

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(preset.name)
                .font(.headline)
                .foregroundStyle(Color("AccentAmber"))
            Text("\(preset.key) \(preset.scaleName) | \(preset.instrumentName): \(preset.tuningName)")
                .font(.caption)
                .foregroundStyle(Color("AccentAmber").opacity(0.7))
            Text("Frets \(preset.startFret)–\(preset.endFret) | Strings \(preset.highString)–\(preset.lowString)")
                .font(.caption)
                .foregroundStyle(Color("AccentAmber").opacity(0.5))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PresetsView()
        .environment(PresetStore())
        .preferredColorScheme(.dark)
}
