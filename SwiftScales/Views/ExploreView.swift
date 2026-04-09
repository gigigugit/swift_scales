import SwiftUI

struct ExploreView: View {
    @State private var vm = FretboardViewModel()
    @State private var showSavePreset = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 12) {

                    // Key + Scale pickers
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Key")
                                .font(.caption)
                                .foregroundStyle(Color("AccentAmber").opacity(0.7))
                            Picker("Key", selection: $vm.selectedKey) {
                                ForEach(notesSharp, id: \.self) { note in
                                    Text(note).tag(note)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color("AccentAmber"))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Scale")
                                .font(.caption)
                                .foregroundStyle(Color("AccentAmber").opacity(0.7))
                            Picker("Scale", selection: $vm.selectedScaleName) {
                                ForEach(Array(scaleIntervals.keys).sorted(), id: \.self) { name in
                                    Text(name).tag(name)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color("AccentAmber"))
                        }

                        Spacer()
                    }
                    .padding(.horizontal)

                    // Fretboard output
                    FretboardOutputView(text: vm.fretboardText)
                        .padding(.horizontal)

                    // Degree toggles
                    DegreeToggleRow(
                        activeDegrees: $vm.activeDegrees,
                        enabled: vm.degreesEnabled
                    )
                    .padding(.horizontal)

                    // Display mode
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Display")
                            .font(.caption)
                            .foregroundStyle(Color("AccentAmber").opacity(0.7))
                        Picker("Display", selection: $vm.displayMode) {
                            ForEach(DisplayMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)

                    Divider().background(Color("AccentAmber").opacity(0.3))

                    // Instrument + Tuning
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Instrument")
                                .font(.caption)
                                .foregroundStyle(Color("AccentAmber").opacity(0.7))
                            Picker("Instrument", selection: $vm.selectedInstrumentName) {
                                ForEach(instruments) { instrument in
                                    Text(instrument.name).tag(instrument.name)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color("AccentAmber"))
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tuning")
                                .font(.caption)
                                .foregroundStyle(Color("AccentAmber").opacity(0.7))
                            Picker("Tuning", selection: $vm.selectedTuningName) {
                                ForEach(vm.availableTunings) { tuning in
                                    Text(tuning.name).tag(tuning.name)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color("AccentAmber"))
                        }
                    }
                    .padding(.horizontal)

                    // Fret range steppers
                    RangeStepperRow(
                        label: "Frets",
                        lowLabel: "Start",
                        highLabel: "End",
                        lowValue: $vm.startFret,
                        highValue: $vm.endFret,
                        range: 0...vm.maxFret
                    )
                    .padding(.horizontal)

                    // String range steppers
                    RangeStepperRow(
                        label: "Strings",
                        lowLabel: "High",
                        highLabel: "Low",
                        lowValue: $vm.highString,
                        highValue: $vm.lowString,
                        range: 1...vm.stringCount
                    )
                    .padding(.horizontal)

                    Divider().background(Color("AccentAmber").opacity(0.3))

                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: vm.copyToClipboard) {
                            Label("Copy", systemImage: "doc.on.doc")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("AccentAmber"))

                        Button(action: { showSavePreset = true }) {
                            Label("Save Preset", systemImage: "star.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color("AccentAmber"))
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                .padding(.top, 12)
            }
            .background(Color("AppBackground"))
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showSavePreset) {
            SavePresetSheet(vm: vm)
        }
    }
}

#Preview {
    ExploreView()
        .environment(PresetStore())
        .preferredColorScheme(.dark)
}
