import SwiftUI

struct SavePresetSheet: View {
    let vm: FretboardViewModel
    @Environment(PresetStore.self) private var presetStore
    @Environment(\.dismiss) private var dismiss

    @State private var presetName: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.caption)
                        .foregroundStyle(Color("AccentAmber").opacity(0.7))
                    TextField("e.g. E Major Standard", text: $presetName)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 15))
                }
                .padding(.horizontal)

                // Summary of what will be saved
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.configSummary)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(Color("AccentAmber").opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(Color("FretboardBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)

                Spacer()

                Button(action: saveAndDismiss) {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentAmber"))
                .disabled(presetName.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .padding(.top, 20)
            .background(Color("AppBackground"))
            .navigationTitle("Save Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .tint(Color("AccentAmber"))
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            presetName = "\(vm.selectedKey) \(vm.selectedScaleName)"
        }
    }

    private func saveAndDismiss() {
        let preset = vm.makePreset(name: presetName.trimmingCharacters(in: .whitespaces))
        presetStore.add(preset)
        dismiss()
    }
}
