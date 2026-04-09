# SwiftScales — Product Roadmap & Data Model Notes

---

## Phase 1 — MVP (this PR)

- [x] Planning docs & wireframes
- [x] Reference Python source preserved
- [x] SwiftUI app scaffold (models, views, entry point)
- [ ] `FretboardViewModel` with full `fretboardText` computation
- [ ] All Explore screen controls wired and functional
- [ ] App runs on simulator and renders correct fretboard output

**Success criterion:** A user can open the app, pick a key and scale, choose an instrument and tuning, adjust fret range, and see a correct monospaced fretboard diagram on screen with Copy working.

---

## Phase 2 — Presets

- [ ] `PresetStore` persists presets to a JSON file
- [ ] PresetsView: list, load, delete
- [ ] SavePresetSheet: name and save current configuration
- [ ] Default preset loaded on first launch

---

## Phase 3 — Settings & Polish

- [ ] SettingsView: default key / scale / instrument / tuning via `@AppStorage`
- [ ] Font size preference
- [ ] About view with version and attribution
- [ ] App icon and launch screen
- [ ] Accessibility labels on all controls

---

## Phase 4 — Enhancements (post-MVP backlog)

| Feature | Notes |
|---|---|
| Flat notation option | Show `Bb` instead of `A#`, etc. |
| Additional scales | Dorian, Mixolydian, Blues, Harmonic Minor, etc. |
| Custom tunings | User-defined open strings |
| Share sheet | Share fretboard diagram as plain text or image |
| iPad layout | Two-column adaptive layout |
| Landscape support | Fretboard scrolls better in landscape on iPhone |
| iCloud sync | Presets across devices via CloudKit |

---

## Data Model Notes

### Chromatic note representation

- MVP uses sharps only: `["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]`.
- Phase 4 adds a user preference to display enharmonic equivalents as flats for relevant notes (`Bb`, `Eb`, `Ab`, `Db`, `Gb`).
- Internally, notes are always stored and computed as sharp-notation indices 0–11.

### Scale degree filtering

- Each scale has between 5 and 7 degrees (pentatonic = 5, heptatonic = 7).
- The degree toggle array is always length 7; indices ≥ scale length are disabled and treated as inactive regardless of their stored value.
- This matches the Python app's `_sync_note_selectors` / `_selected_scale_notes` logic.

### Fretboard text rendering algorithm

Mirrors the Python `_update_output` method:

```
1. header = "{key} {scale} | {instrument}: {tuning} | Frets {start}-{end}"
2. fretLine = "Fret:" + for each fret in range:
       if fret in fretMarkers → right-justified fret number (width 2 for first cell, 3 for rest)
       else → spaces of same width
3. divider = "-" * max(len(header), len(fretLine))
4. for each string in display range (high → low):
       openIndex = noteIndex(openString)
       row = "{openNote} |" + for each fret:
           note = notesSharp[(openIndex + fret) % 12]
           if note in activeNoteSet → formatCell(displayMode, fret, note, degreeMap)
           else → " --"
```

`formatCell`:
- `fretNumber` → `String(format: "%3d", fret)`
- `note` → right-justified note name in 3 chars
- `interval` → right-justified degree label in 3 chars

### Preset storage schema

```json
[
  {
    "id": "UUID-string",
    "name": "E Major Standard",
    "key": "E",
    "scaleName": "Major",
    "instrumentName": "Guitar",
    "tuningName": "Standard (EADGBE)",
    "startFret": 0,
    "endFret": 18,
    "highString": 1,
    "lowString": 6,
    "displayMode": "Fret #",
    "activeDegrees": [true,true,true,true,true,true,true]
  }
]
```

File location: `FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]/presets.json`

---

## Design Constraints Carried Forward from Python App

1. **Text-output first.** The fretboard is rendered as plain text, not as a custom-drawn canvas. This keeps the implementation simple, the output copyable, and the aesthetic consistent with the original.
2. **Dark palette.** `#1C1C1E` background, `#CC7033` amber accent — no bright white surfaces.
3. **No frills.** Standard iOS controls (pickers, steppers, toggles). No custom sliders, no animations beyond system defaults.
4. **Utility over aesthetics.** Information density is preferred; the text block can be small to fit more frets on screen.
