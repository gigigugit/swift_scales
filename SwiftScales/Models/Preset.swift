import Foundation

/// A saved configuration that can be loaded back into the Explore view.
struct Preset: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String

    // Selection
    var key: String
    var scaleName: String
    var instrumentName: String
    var tuningName: String

    // Ranges
    var startFret: Int
    var endFret: Int
    var highString: Int
    var lowString: Int

    // Display
    var displayMode: String

    /// 7 elements; `false` means that scale degree is toggled off.
    var activeDegrees: [Bool]
}
