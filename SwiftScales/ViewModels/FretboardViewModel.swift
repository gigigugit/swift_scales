import Foundation
import Observation
import UIKit

/// Drives the Explore screen. All fretboard output is derived from the stored inputs.
@Observable
final class FretboardViewModel {

    // MARK: - Inputs

    var selectedKey: String = "E"
    var selectedScaleName: String = "Major"
    var selectedInstrumentName: String = "Guitar"
    var selectedTuningName: String = "Standard (EADGBE)"
    var startFret: Int = 0
    var endFret: Int = 18
    var highString: Int = 1
    var lowString: Int = 6
    var displayMode: DisplayMode = .fretNumber
    /// 7-element array; index 0 = degree I, etc.
    var activeDegrees: [Bool] = Array(repeating: true, count: 7)

    // MARK: - Derived: instrument/tuning helpers

    var availableTunings: [Tuning] {
        instrument(named: selectedInstrumentName)?.tunings ?? []
    }

    var maxFret: Int {
        instrument(named: selectedInstrumentName)?.defaultMaxFret ?? 24
    }

    var stringCount: Int {
        tuning(instrumentName: selectedInstrumentName,
               tuningName: selectedTuningName)?.strings.count ?? 6
    }

    // MARK: - Derived: scale helpers

    var scaleNotes: [String] {
        buildScaleNotes(key: selectedKey, scaleName: selectedScaleName)
    }

    /// Which degree indices (0-based) are within the current scale.
    var degreesEnabled: [Bool] {
        (0..<7).map { $0 < scaleNotes.count }
    }

    /// The set of note names that are currently active (in scale + degree toggle on).
    var activeNoteSet: Set<String> {
        var result: Set<String> = []
        for (index, note) in scaleNotes.enumerated() where index < 7 {
            if activeDegrees[index] {
                result.insert(note)
            }
        }
        return result
    }

    // MARK: - Fretboard text output

    /// Full plain-text fretboard diagram, mirrors Python _update_output logic.
    var fretboardText: String {
        guard let currentTuning = tuning(
            instrumentName: selectedInstrumentName,
            tuningName: selectedTuningName
        ) else { return "" }

        let start = min(startFret, endFret)
        let end   = max(startFret, endFret)
        let high  = min(highString, lowString)
        let low   = max(highString, lowString)

        let degreeMap = noteDegreeMap(scaleNotes: scaleNotes)

        // Tuning high→low for display
        let stringsHighToLow = currentTuning.strings.reversed()

        let header   = "\(selectedKey) \(selectedScaleName) | \(selectedInstrumentName): \(selectedTuningName) | Frets \(start)-\(end)"
        let fretLine = buildFretMarkerLine(start: start, end: end)
        let divider  = String(repeating: "-", count: max(header.count, fretLine.count))

        var lines = [header, fretLine, divider]

        let displayRange = high...low
        for (idx, openNote) in stringsHighToLow.enumerated() {
            let stringNumber = idx + 1
            guard displayRange.contains(stringNumber) else { continue }
            guard let openIndex = notesSharp.firstIndex(of: openNote) else { continue }

            var row = "\(openNote.padding(toLength: 2, withPad: " ", startingAt: 0)) |"
            for fret in start...end {
                let note = notesSharp[(openIndex + fret) % 12]
                if activeNoteSet.contains(note) {
                    row += formatCell(fret: fret, note: note, degreeMap: degreeMap)
                } else {
                    row += " --"
                }
            }
            lines.append(row)
        }

        return lines.joined(separator: "\n")
    }

    // MARK: - Actions

    func copyToClipboard() {
        UIPasteboard.general.string = fretboardText
    }

    func makePreset(name: String) -> Preset {
        Preset(
            name: name,
            key: selectedKey,
            scaleName: selectedScaleName,
            instrumentName: selectedInstrumentName,
            tuningName: selectedTuningName,
            startFret: startFret,
            endFret: endFret,
            highString: highString,
            lowString: lowString,
            displayMode: displayMode.rawValue,
            activeDegrees: activeDegrees
        )
    }

    func load(preset: Preset) {
        selectedKey            = preset.key
        selectedScaleName      = preset.scaleName
        selectedInstrumentName = preset.instrumentName
        selectedTuningName     = preset.tuningName
        startFret              = preset.startFret
        endFret                = preset.endFret
        highString             = preset.highString
        lowString              = preset.lowString
        displayMode            = DisplayMode(rawValue: preset.displayMode) ?? .fretNumber
        activeDegrees          = preset.activeDegrees
    }

    /// One-line human-readable summary of the current configuration.
    var configSummary: String {
        "\(selectedKey) \(selectedScaleName) | \(selectedInstrumentName): \(selectedTuningName)\nFrets \(startFret)–\(endFret) | Strings \(highString)–\(lowString)"
    }

    // MARK: - Private helpers

    private func buildFretMarkerLine(start: Int, end: Int) -> String {
        var parts = ["Fret:"]
        var isFirst = true
        for fret in start...end {
            let width = isFirst ? 2 : 3
            if fretMarkers.contains(fret) {
                parts.append(String(format: "%\(width)d", fret))
            } else {
                parts.append(String(repeating: " ", count: width))
            }
            isFirst = false
        }
        return parts.joined()
    }

    private func formatCell(fret: Int, note: String, degreeMap: [String: String]) -> String {
        switch displayMode {
        case .fretNumber:
            return String(format: "%3d", fret)
        case .note:
            // Right-pad to 3 characters to maintain column alignment
            let padded = note + String(repeating: " ", count: max(0, 3 - note.count))
            return padded
        case .interval:
            let label = degreeMap[note] ?? "1"
            let padded = label + String(repeating: " ", count: max(0, 3 - label.count))
            return padded
        }
    }
}
