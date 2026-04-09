// Music theory data: chromatic notes, scale intervals, degree labels, fret markers.

/// All twelve chromatic notes using sharp notation.
let notesSharp: [String] = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

/// Scale name → semitone intervals from root (0 = root).
let scaleIntervals: [String: [Int]] = [
    "Major":            [0, 2, 4, 5, 7, 9, 11],
    "Minor":            [0, 2, 3, 5, 7, 8, 10],
    "Pentatonic Major": [0, 2, 4, 7, 9],
    "Pentatonic Minor": [0, 3, 5, 7, 10],
]

/// Roman-numeral degree labels (I–VII).
let romanLabels: [String] = ["I", "II", "III", "IV", "V", "VI", "VII"]

/// Numeric degree labels (1–7).
let intervalLabels: [String] = ["1", "2", "3", "4", "5", "6", "7"]

/// Fret positions that carry a fret-marker dot on a standard instrument.
let fretMarkers: Set<Int> = [0, 3, 5, 7, 9, 12, 15, 17, 19, 21, 24]

// MARK: - Helpers

/// Returns the ordered scale notes for a given key and scale name.
func buildScaleNotes(key: String, scaleName: String) -> [String] {
    guard let rootIndex = notesSharp.firstIndex(of: key),
          let intervals = scaleIntervals[scaleName] else { return [] }
    return intervals.map { notesSharp[(rootIndex + $0) % 12] }
}

/// Maps each scale note to its numeric degree label ("1", "2", …).
func noteDegreeMap(scaleNotes: [String]) -> [String: String] {
    var map: [String: String] = [:]
    for (index, note) in scaleNotes.enumerated() where index < intervalLabels.count {
        map[note] = intervalLabels[index]
    }
    return map
}
