# SwiftScales — SwiftUI Architecture Blueprint

_iOS 17+, SwiftUI, no external dependencies_

---

## Project Structure

```
SwiftScales/
├── SwiftScalesApp.swift            ← @main entry point
├── ContentView.swift               ← root TabView
│
├── Views/
│   ├── ExploreView.swift           ← main fretboard screen
│   ├── FretboardOutputView.swift   ← scrollable monospaced text block
│   ├── DegreeToggleRow.swift       ← I–VII toggle buttons
│   ├── RangeStepperRow.swift       ← reusable stepper pair (fret range, string range)
│   ├── PresetsView.swift           ← preset list screen
│   ├── SavePresetSheet.swift       ← bottom sheet to name + save a preset
│   └── SettingsView.swift          ← app settings screen
│
├── ViewModels/
│   └── FretboardViewModel.swift    ← @Observable; drives ExploreView
│
└── Models/
    ├── ScaleModel.swift            ← notes, scales, intervals, degree labels
    ├── InstrumentModel.swift       ← instruments, tunings, default max frets
    ├── DisplayModel.swift          ← DisplayMode enum, font size enum
    ├── Preset.swift                ← Codable preset struct
    └── PresetStore.swift           ← persistence (UserDefaults / JSON file)
```

---

## Models

### `ScaleModel.swift`

```swift
// Chromatic notes (sharps only for MVP)
let notesSharp: [String] = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]

// Scale name → semitone intervals from root
let scaleIntervals: [String: [Int]] = [
    "Major":            [0,2,4,5,7,9,11],
    "Minor":            [0,2,3,5,7,8,10],
    "Pentatonic Major": [0,2,4,7,9],
    "Pentatonic Minor": [0,3,5,7,10],
]

let romanLabels:    [String] = ["I","II","III","IV","V","VI","VII"]
let intervalLabels: [String] = ["1","2","3","4","5","6","7"]
let fretMarkers:    Set<Int> = [0,3,5,7,9,12,15,17,19,21,24]

// Helpers
func buildScaleNotes(key: String, scaleName: String) -> [String]
func noteDegreeMap(scaleNotes: [String]) -> [String: String]
```

### `InstrumentModel.swift`

```swift
struct Tuning: Identifiable {
    let id = UUID()
    let name: String
    let strings: [String]   // low to high
}

struct Instrument: Identifiable {
    let id = UUID()
    let name: String
    let tunings: [Tuning]
    let defaultMaxFret: Int
}

let instruments: [Instrument] = [
    Instrument(name: "Guitar", defaultMaxFret: 18, tunings: [
        Tuning(name: "Standard (EADGBE)", strings: ["E","A","D","G","B","E"]),
        Tuning(name: "Drop D (DADGBE)",   strings: ["D","A","D","G","B","E"]),
        Tuning(name: "Open G (DGDGBD)",   strings: ["D","G","D","G","B","D"]),
    ]),
    Instrument(name: "Banjo", defaultMaxFret: 22, tunings: [
        Tuning(name: "Standard (GDGBD)", strings: ["G","D","G","B","D"]),
    ]),
]
```

### `DisplayModel.swift`

```swift
enum DisplayMode: String, CaseIterable, Identifiable {
    case fretNumber = "Fret #"
    case note       = "Note"
    case interval   = "Interval"
    var id: String { rawValue }
}

enum FretboardFontSize: String, CaseIterable {
    case small  = "Small"
    case medium = "Medium"
    case large  = "Large"

    var pointSize: CGFloat {
        switch self { case .small: 10; case .medium: 12; case .large: 14 }
    }
}
```

### `Preset.swift`

```swift
struct Preset: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var key: String
    var scaleName: String
    var instrumentName: String
    var tuningName: String
    var startFret: Int
    var endFret: Int
    var highString: Int
    var lowString: Int
    var displayMode: String
    var activeDegrees: [Bool]   // 7 elements; false = degree toggled off
}
```

### `PresetStore.swift`

```swift
@Observable
class PresetStore {
    var presets: [Preset] = []
    // load() / save() backed by a JSON file in the app's Documents directory
}
```

---

## ViewModel

### `FretboardViewModel.swift`

```swift
@Observable
class FretboardViewModel {
    // --- Inputs (bound to controls) ---
    var selectedKey: String         = "E"
    var selectedScaleName: String   = "Major"
    var selectedInstrument: Instrument
    var selectedTuning: Tuning
    var startFret: Int              = 0
    var endFret: Int                = 18
    var highString: Int             = 1
    var lowString: Int              = 6
    var displayMode: DisplayMode    = .fretNumber
    var activeDegrees: [Bool]       = Array(repeating: true, count: 7)

    // --- Derived (computed) ---
    var fretboardText: String { ... }   // full plain-text diagram
    var scaleNotes: [String]     { ... }
    var activeNoteSet: Set<String> { ... }
    var degreesEnabled: [Bool]   { ... }  // false for indices >= scale length

    // --- Actions ---
    func copyToClipboard()
    func makePreset(name: String) -> Preset
    func load(preset: Preset)
}
```

`fretboardText` mirrors the Python `_update_output` logic:
1. Build header line.
2. Build fret-marker line.
3. Build one row per string in display range (high → low).
4. Each cell: `_format_cell` equivalent in Swift.

---

## Views

### `ExploreView.swift`

- `@State var vm = FretboardViewModel()`
- Top bar: key `Picker` + scale `Picker` (inline or `.menu` style).
- `FretboardOutputView(text: vm.fretboardText)` — the scrollable diagram.
- `DegreeToggleRow(activeDegrees: $vm.activeDegrees, enabled: vm.degreesEnabled)`.
- Display mode segmented `Picker`.
- Instrument + tuning `Picker`s.
- Fret range `RangeStepperRow` + string range `RangeStepperRow`.
- Copy / Save Preset buttons.
- `.sheet(isPresented:)` for `SavePresetSheet`.

### `FretboardOutputView.swift`

```swift
struct FretboardOutputView: View {
    let text: String
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            Text(text)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color("AccentAmber"))
                .padding(8)
        }
        .background(Color("FretboardBackground"))
        .cornerRadius(8)
    }
}
```

### `PresetsView.swift`

- `@Environment(PresetStore.self)` to read/write presets.
- `List` of preset rows; swipe-to-delete.
- Tap row → calls `vm.load(preset:)` + switch tab via `@Environment(\.tabSelection)` or a shared binding.

### `SettingsView.swift`

- `Form` with `Picker`s for default key, scale, instrument, tuning.
- `Picker` for font size preference.
- Navigation link to About view.

---

## Data Flow

```
User interaction
      │
      ▼
FretboardViewModel (@Observable)
      │  (computed var)
      ▼
fretboardText: String
      │
      ▼
FretboardOutputView (Text in ScrollView)
```

No Combine, no async networking. All state is synchronous and local for MVP.

---

## Persistence

| Data | Storage |
|---|---|
| Presets | JSON file in app Documents via `PresetStore` |
| App settings (defaults) | `UserDefaults` via `@AppStorage` |

---

## Color Palette (`Assets.xcassets`)

| Name | Light | Dark |
|---|---|---|
| `AppBackground` | `#F2F2F7` | `#1C1C1E` |
| `FretboardBackground` | `#E5E5EA` | `#2C2C2E` |
| `AccentAmber` | `#CC7033` | `#CC7033` |

---

## Implementation Order

1. **Models** — `ScaleModel`, `InstrumentModel`, `DisplayModel` (pure data, unit-testable).
2. **FretboardViewModel** — wire up `fretboardText` computation; verify output matches Python reference.
3. **FretboardOutputView** + `ExploreView` skeleton — get the fretboard rendering on screen.
4. **Degree toggles + display mode** — complete all Explore controls.
5. **Preset model + store** — `Preset`, `PresetStore`, `SavePresetSheet`.
6. **PresetsView** — list, load, delete.
7. **SettingsView** — defaults + font size.
8. **Polish** — keyboard handling, accessibility labels, app icon, launch screen.

---

## Out of Scope for MVP

- Flat/natural accidental notation (sharps only).
- Custom tunings.
- iPad layout.
- iCloud sync.
- Audio playback.
- Widget or Watch extension.
