import Foundation

// MARK: - Display Mode

/// How each fret cell is labelled in the fretboard diagram.
enum DisplayMode: String, CaseIterable, Identifiable, Codable {
    case fretNumber = "Fret #"
    case note       = "Note"
    case interval   = "Interval"

    var id: String { rawValue }
}

// MARK: - Font Size

/// User-selectable font size for the fretboard output block.
enum FretboardFontSize: String, CaseIterable, Codable {
    case small  = "Small"
    case medium = "Medium"
    case large  = "Large"

    var pointSize: CGFloat {
        switch self {
        case .small:  return 10
        case .medium: return 12
        case .large:  return 14
        }
    }
}
