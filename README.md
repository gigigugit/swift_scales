# SwiftScales

A no-frills, high-utility iOS scale reference app for guitar and other fretted instruments — a SwiftUI rewrite of an existing Python/PyQt fretboard viewer.

---

## App Vision

SwiftScales puts a practical scale reference tool in your pocket. The goal is fast, distraction-free access to fretboard scale maps during practice or performance. The aesthetic is dark, monospaced, and text-forward — faithful to the terminal-style output of the original Python app.

---

## Feature Set (MVP)

| Feature | Description |
|---|---|
| Key selection | All 12 chromatic keys |
| Scale selection | Major, Minor, Pentatonic Major, Pentatonic Minor (expandable) |
| Instrument & tuning | Guitar (Standard, Drop D, Open G), Banjo (Standard) |
| Fret range | Configurable start/end fret |
| String range | Configurable high/low string |
| Display mode | Fret number, Note name, Interval (scale degree) |
| Note-degree filter | Toggle individual scale degrees on/off |
| Text fretboard output | Monospaced ASCII-style fretboard diagram |
| Presets | Save/load favourite key+scale+tuning combinations |

---

## Development Direction

- **Platform:** iOS 17+, iPhone-first, Dark Mode default.
- **Framework:** SwiftUI, no external dependencies in v1.
- **Architecture:** Lightweight MVVM. A single `FretboardViewModel` drives the main fretboard view; pure model structs hold music theory data.
- **Text-output mindset preserved:** The fretboard diagram remains a monospaced text block — readable, copyable, shareable.
- **Xcode project:** Located at `SwiftScales/` in this repository.

---

## Repository Layout

```
swift_scales/
├── README.md                  ← this file
├── docs/
│   ├── wireframe_spec.md      ← screen-by-screen wireframe & interaction spec
│   ├── architecture_blueprint.md  ← SwiftUI project blueprint
│   └── roadmap.md             ← product roadmap & data model notes
├── reference/
│   └── guitar_scale_tab_viewer_working.pyw  ← original Python/PyQt source
└── SwiftScales/               ← SwiftUI app scaffold
    ├── SwiftScalesApp.swift
    ├── ContentView.swift
    ├── Views/
    │   ├── ExploreView.swift
    │   ├── PresetsView.swift
    │   └── SettingsView.swift
    └── Models/
        ├── ScaleModel.swift
        ├── InstrumentModel.swift
        └── DisplayModel.swift
```

---

## Reference Source

The original Python/PyQt application lives at `reference/guitar_scale_tab_viewer_working.pyw` and serves as the functional specification for the iOS rewrite.

---

## Getting Started

1. Open `SwiftScales/SwiftScales.xcodeproj` (to be created) in Xcode 15+.
2. Select an iPhone simulator and run.
3. See `docs/architecture_blueprint.md` for implementation order.
