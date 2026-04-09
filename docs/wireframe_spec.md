# SwiftScales — Wireframe & Screen Spec

_iPhone-first, Dark Mode, iOS 17+_

---

## Navigation Model

Three-tab bottom navigation:

```
[ Explore ]  [ Presets ]  [ Settings ]
```

---

## Screen 1 — Explore (Main Fretboard View)

### Purpose
Primary utility screen. User configures a key, scale, instrument, and display options; the app renders a scrollable monospaced fretboard diagram.

### Layout

```
┌──────────────────────────────────────┐
│  [Key ▾]   [Scale ▾]                 │  ← top bar (sticky)
│  E  Major                            │
├──────────────────────────────────────┤
│                                      │
│  ┌────────────────────────────────┐  │
│  │  E Major | Guitar: Standard    │  │  ← header line (monospace)
│  │  Fret:  0  3  5  7  9 12 15   │  │
│  │  ─────────────────────────── │  │
│  │  E |  0 -- -- -- -- 12 --    │  │  ← string rows (monospace)
│  │  B | --  3 --  7 --  -- 15   │  │
│  │  G | --  4  5 --  9  -- --   │  │
│  │  D | --  2 -- --  7  --  9   │  │
│  │  A |  0 -- --  5 -- --  12   │  │
│  │  E |  0 -- --  -- --  9  12  │  │
│  └────────────────────────────────┘  │
│  (horizontally scrollable)           │
│                                      │
├──────────────────────────────────────┤
│  Display: [Fret # ▾]                 │  ← display mode picker
│  Degrees: [I][II][III][IV][V][VI][VII]│  ← degree toggle row
├──────────────────────────────────────┤
│  [Instrument ▾]  [Tuning ▾]          │  ← instrument row
│  Frets: [0] – [18]   Strings: [1]–[6]│  ← range steppers
├──────────────────────────────────────┤
│  [ Copy ]    [ Save Preset ]         │  ← action buttons
└──────────────────────────────────────┘
```

### Components

| Component | Type | Notes |
|---|---|---|
| Key picker | Wheel / segmented | 12 chromatic notes |
| Scale picker | Picker / wheel | Major, Minor, Pent. Maj, Pent. Min |
| Fretboard output | `ScrollView` + `Text` | Monospaced font, horizontally scrollable |
| Display mode | `Picker` (segmented) | Fret Number / Note / Interval |
| Degree toggles | `Toggle` row (I–VII) | Greys out degrees outside scale length |
| Instrument picker | `Picker` | Guitar, Banjo |
| Tuning picker | `Picker` | Dependent on instrument |
| Fret range | Stepper pair (start / end) | Clamped to max fret |
| String range | Stepper pair (high / low) | Clamped to string count |
| Copy button | `Button` | Copies plain-text fretboard to clipboard |
| Save Preset button | `Button` | Saves current configuration as a named preset |

### Interactions

- Changing key, scale, instrument, tuning, fret range, string range, or degree toggles → fretboard updates immediately.
- Degree toggle is automatically disabled/greyed for degrees beyond current scale length (e.g. pentatonic scales only have 5 degrees).
- Tapping **Copy** copies the plain-text fretboard string to the clipboard.
- Tapping **Save Preset** presents a sheet to name and save the current configuration.

---

## Screen 2 — Presets

### Purpose
Browse, load, and delete saved configurations (key + scale + instrument + tuning + display options).

### Layout

```
┌──────────────────────────────────────┐
│  Presets                     [+ Add] │  ← nav bar
├──────────────────────────────────────┤
│  ┌────────────────────────────────┐  │
│  │  E Major / Guitar Standard    │  │  ← preset row
│  │  Frets 0–18, all degrees      │  │
│  └────────────────────────────────┘  │
│  ┌────────────────────────────────┐  │
│  │  A Minor / Guitar Drop D      │  │
│  │  Frets 5–12, degrees I III V  │  │
│  └────────────────────────────────┘  │
│  …                                   │
└──────────────────────────────────────┘
```

### Interactions

- Tapping a preset row → loads its configuration into the Explore screen and switches to Explore tab.
- Swipe-to-delete → removes the preset (with confirmation).
- `[+ Add]` button → same as "Save Preset" from Explore; opens the save sheet.

---

## Screen 3 — Settings

### Purpose
App-level preferences.

### Layout

```
┌──────────────────────────────────────┐
│  Settings                            │
├──────────────────────────────────────┤
│  Default Key          [E  ▾]         │
│  Default Scale        [Major ▾]      │
│  Default Instrument   [Guitar ▾]     │
│  Default Tuning       [Standard ▾]   │
├──────────────────────────────────────┤
│  Font Size            [Medium ▾]     │
├──────────────────────────────────────┤
│  About SwiftScales    >              │
└──────────────────────────────────────┘
```

### Interactions

- All pickers persist via `UserDefaults`.
- About row → pushes a simple credits/version view.

---

## Save Preset Sheet

Presented as a bottom sheet from Explore or Presets.

```
┌──────────────────────────────────────┐
│  Save Preset                    [✕]  │
│                                      │
│  Name: [E Major Standard__________]  │
│                                      │
│  E Major | Guitar: Standard          │
│  Frets 0–18 | All degrees            │
│                                      │
│         [ Save ]                     │
└──────────────────────────────────────┘
```

---

## About View

Simple pushed view:

```
┌──────────────────────────────────────┐
│  < Settings   About SwiftScales      │
├──────────────────────────────────────┤
│                                      │
│  SwiftScales v1.0                    │
│  A fretboard scale reference tool.   │
│                                      │
│  Original concept: Python/PyQt app   │
│  Rewritten in SwiftUI for iOS.       │
│                                      │
└──────────────────────────────────────┘
```

---

## Visual Design Notes

- **Background:** `#1C1C1E` (iOS system dark / near-black)
- **Accent / text:** `#CC7033` (amber-orange, matching the Python app palette)
- **Fretboard output font:** `Font.system(.body, design: .monospaced)` — matches the Consolas style of the original
- **Controls:** standard iOS pickers and steppers; no custom chrome required for MVP
- **Fretboard area:** `ScrollView(.horizontal)` wrapping a single `Text` block for simplicity
