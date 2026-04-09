import Foundation

// MARK: - Data Types

struct Tuning: Identifiable, Hashable, Codable {
    var id: String { name }
    let name: String
    /// Open-string notes from low (thickest) to high (thinnest).
    let strings: [String]
}

struct Instrument: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let tunings: [Tuning]
    let defaultMaxFret: Int
}

// MARK: - Data

/// All supported instruments and their tunings.
let instruments: [Instrument] = [
    Instrument(
        name: "Guitar",
        tunings: [
            Tuning(name: "Standard (EADGBE)", strings: ["E", "A", "D", "G", "B", "E"]),
            Tuning(name: "Drop D (DADGBE)",   strings: ["D", "A", "D", "G", "B", "E"]),
            Tuning(name: "Open G (DGDGBD)",   strings: ["D", "G", "D", "G", "B", "D"]),
        ],
        defaultMaxFret: 18
    ),
    Instrument(
        name: "Banjo",
        tunings: [
            Tuning(name: "Standard (GDGBD)", strings: ["G", "D", "G", "B", "D"]),
        ],
        defaultMaxFret: 22
    ),
]

// MARK: - Lookup Helpers

func instrument(named name: String) -> Instrument? {
    instruments.first(where: { $0.name == name })
}

func tuning(instrumentName: String, tuningName: String) -> Tuning? {
    instrument(named: instrumentName)?.tunings.first(where: { $0.name == tuningName })
}
