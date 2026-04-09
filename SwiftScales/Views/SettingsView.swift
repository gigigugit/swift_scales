import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultKey") private var defaultKey = "E"
    @AppStorage("defaultScale") private var defaultScale = "Major"
    @AppStorage("defaultInstrument") private var defaultInstrument = "Guitar"
    @AppStorage("defaultTuning") private var defaultTuning = "Standard (EADGBE)"
    @AppStorage("fretboardFontSize") private var fontSizeRaw = FretboardFontSize.medium.rawValue

    private var availableTunings: [Tuning] {
        instruments.first(where: { $0.name == defaultInstrument })?.tunings ?? []
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Defaults") {
                    Picker("Key", selection: $defaultKey) {
                        ForEach(notesSharp, id: \.self) { note in
                            Text(note).tag(note)
                        }
                    }
                    .tint(Color("AccentAmber"))

                    Picker("Scale", selection: $defaultScale) {
                        ForEach(Array(scaleIntervals.keys).sorted(), id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .tint(Color("AccentAmber"))

                    Picker("Instrument", selection: $defaultInstrument) {
                        ForEach(instruments) { instrument in
                            Text(instrument.name).tag(instrument.name)
                        }
                    }
                    .tint(Color("AccentAmber"))

                    Picker("Tuning", selection: $defaultTuning) {
                        ForEach(availableTunings) { tuning in
                            Text(tuning.name).tag(tuning.name)
                        }
                    }
                    .tint(Color("AccentAmber"))
                }

                Section("Display") {
                    Picker("Font Size", selection: $fontSizeRaw) {
                        ForEach(FretboardFontSize.allCases, id: \.rawValue) { size in
                            Text(size.rawValue).tag(size.rawValue)
                        }
                    }
                    .tint(Color("AccentAmber"))
                }

                Section {
                    NavigationLink("About SwiftScales") {
                        AboutView()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color("AppBackground"))
            .navigationTitle("Settings")
            .foregroundStyle(Color("AccentAmber"))
        }
    }
}

private struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("SwiftScales")
                        .font(.headline)
                    Text("Version 1.0")
                        .font(.subheadline)
                }
                .foregroundStyle(Color("AccentAmber"))
                .listRowBackground(Color("FretboardBackground"))
            }
            Section {
                Text("A fretboard scale reference tool for guitar and other fretted instruments.")
                    .foregroundStyle(Color("AccentAmber").opacity(0.8))
                    .listRowBackground(Color("FretboardBackground"))
            }
            Section("Origin") {
                Text("Originally a Python/PyQt desktop application. Rewritten in SwiftUI for iPhone.")
                    .foregroundStyle(Color("AccentAmber").opacity(0.8))
                    .listRowBackground(Color("FretboardBackground"))
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color("AppBackground"))
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
