import Foundation
import Observation

/// Persists presets to a JSON file in the app's Documents directory.
@Observable
final class PresetStore {
    private(set) var presets: [Preset] = []

    private var fileURL: URL {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("presets.json")
    }

    init() {
        load()
    }

    // MARK: - CRUD

    func add(_ preset: Preset) {
        presets.append(preset)
        save()
    }

    func delete(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
        save()
    }

    func update(_ preset: Preset) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        presets[index] = preset
        save()
    }

    // MARK: - Persistence

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path()),
              let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Preset].self, from: data)
        else { return }
        presets = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(presets) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
