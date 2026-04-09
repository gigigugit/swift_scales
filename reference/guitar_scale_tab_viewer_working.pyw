import sys
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont, QColor, QPalette
from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QWidget, QTextEdit, QComboBox, QPushButton,
    QVBoxLayout, QHBoxLayout, QLabel, QFileDialog, QSizePolicy,
    QSpinBox, QGridLayout, QCheckBox
)


NOTES_SHARP = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

SCALE_INTERVALS = {
    "Major": [0, 2, 4, 5, 7, 9, 11],
    "Minor": [0, 2, 3, 5, 7, 8, 10],
    "Pentatonic Major": [0, 2, 4, 7, 9],
    "Pentatonic Minor": [0, 3, 5, 7, 10],
}

INSTRUMENTS = {
    "Guitar": {
        "Standard (EADGBE)": ["E", "A", "D", "G", "B", "E"],  # low to high
        "Drop D (DADGBE)": ["D", "A", "D", "G", "B", "E"],
        "Open G (DGDGBD)": ["D", "G", "D", "G", "B", "D"],
    },
    "Banjo": {
        "Standard (GDGBD)": ["G", "D", "G", "B", "D"],  # low to high
    },
}

INSTRUMENT_DEFAULT_MAX_FRETS = {
    "Guitar": 18,
    "Banjo": 22,
}

ROMAN_LABELS = ["I", "II", "III", "IV", "V", "VI", "VII"]
INTERVAL_LABELS = ["1", "2", "3", "4", "5", "6", "7"]

FRET_MARKERS = {0, 1, 3, 5, 7, 9, 12, 15, 17}


class GuitarScaleApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Scale Fretboard")
        self.resize(1200, 560)

        self.current_max_fret = 24

        self._build_ui()
        self._update_output()

    def _build_ui(self):
        central = QWidget()
        self.setCentralWidget(central)

        central.setStyleSheet(
            """
            QWidget {
                background-color: #202020;
                color: #CC7033;
            }
            QLabel, QCheckBox, QPushButton, QComboBox, QSpinBox {
                color: #CC7033;
            }
            QComboBox QAbstractItemView {
                background-color: #202020;
                color: #CC7033;
                selection-background-color: #303030;
            }
            QCheckBox::indicator {
                width: 14px;
                height: 14px;
                border: 1px solid #CC7033;
                background-color: #2a2a2a;
            }
            QCheckBox::indicator:checked {
                background-color: #CC7033;
            }
            """
        )

        main_layout = QVBoxLayout()
        main_layout.setContentsMargins(12, 8, 12, 10)
        main_layout.setSpacing(8)
        central.setLayout(main_layout)

        # Top row: left label + centered key/scale
        top_row = QHBoxLayout()
        self.fret_range_label = QLabel("Fret Range: 0 - 24")
        top_row.addWidget(self.fret_range_label)

        top_row.addStretch()

        center_controls = QHBoxLayout()
        self.key_combo = QComboBox()
        self.key_combo.addItems(NOTES_SHARP)
        self.key_combo.currentIndexChanged.connect(self._update_output)

        self.scale_combo = QComboBox()
        self.scale_combo.addItems(list(SCALE_INTERVALS.keys()))
        self.scale_combo.currentIndexChanged.connect(self._update_output)

        center_controls.addWidget(QLabel("Select Key"))
        center_controls.addWidget(self.key_combo)
        center_controls.addSpacing(8)
        center_controls.addWidget(QLabel("Select Scale"))
        center_controls.addWidget(self.scale_combo)

        top_row.addLayout(center_controls)
        top_row.addStretch()

        main_layout.addLayout(top_row)

        # Main content row: left column (text + notes + bottom) + right selectors
        content_layout = QHBoxLayout()
        content_layout.setSpacing(14)
        content_layout.setAlignment(Qt.AlignmentFlag.AlignTop)

        # Left column
        left_column = QVBoxLayout()
        left_column.setSpacing(6)

        self.text_display = QTextEdit()
        self.text_display.setReadOnly(True)
        self.text_display.setTextInteractionFlags(
            Qt.TextInteractionFlag.TextSelectableByMouse
            | Qt.TextInteractionFlag.TextSelectableByKeyboard
        )
        self.text_display.setFont(QFont("Consolas", 11))
        self.text_display.setLineWrapMode(QTextEdit.LineWrapMode.NoWrap)
        self.text_display.setSizePolicy(QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Fixed)
        line_height = self.text_display.fontMetrics().lineSpacing()
        self.text_display.setFixedHeight(line_height * 10 + 24)
        self.text_display.setStyleSheet(
            "QTextEdit { background-color: #2f2f2f; border: 1px solid #444; border-radius: 6px; color: #CC8352; }"
        )

        left_column.addWidget(self.text_display)

        # Notes displayed row (under text box)
        notes_row = QHBoxLayout()
        notes_row.setSpacing(6)
        notes_row.addWidget(QLabel("Notes displayed:"))

        self.note_checkboxes = []
        for label in ROMAN_LABELS:
            checkbox = QCheckBox(label)
            checkbox.setChecked(True)
            checkbox.stateChanged.connect(self._update_output)
            self.note_checkboxes.append(checkbox)
            notes_row.addWidget(checkbox)

        notes_row.addStretch()

        self.display_mode_combo = QComboBox()
        self.display_mode_combo.addItems(["Fret Number", "Note", "Interval"])
        self.display_mode_combo.currentIndexChanged.connect(self._update_output)

        notes_row.addWidget(QLabel("Display:"))
        notes_row.addWidget(self.display_mode_combo)

        left_column.addLayout(notes_row)

        # Bottom row (under notes row) aligned to text box width
        bottom_layout = QHBoxLayout()
        bottom_layout.setSpacing(10)

        self.instrument_combo = QComboBox()
        self.instrument_combo.addItems(list(INSTRUMENTS.keys()))
        self.instrument_combo.currentIndexChanged.connect(self._instrument_changed)

        self.tuning_combo = QComboBox()
        self.tuning_combo.currentIndexChanged.connect(self._update_output)

        bottom_layout.addWidget(QLabel("Instrument"))
        bottom_layout.addWidget(self.instrument_combo)
        bottom_layout.addWidget(QLabel("Select Tuning"))
        bottom_layout.addWidget(self.tuning_combo)
        bottom_layout.addStretch()

        self.save_button = QPushButton("Save")
        self.save_button.clicked.connect(self._save_text)

        self.copy_button = QPushButton("Copy")
        self.copy_button.clicked.connect(self._copy_text)

        self.exit_button = QPushButton("Exit")
        self.exit_button.clicked.connect(self.close)

        bottom_layout.addWidget(self.save_button)
        bottom_layout.addWidget(self.copy_button)
        bottom_layout.addWidget(self.exit_button)

        left_column.addLayout(bottom_layout)

        # Right column: selectors
        right_column = QVBoxLayout()
        right_column.setSpacing(6)
        right_column.setAlignment(Qt.AlignmentFlag.AlignTop)

        selector_box = QWidget()
        selector_layout = QGridLayout()
        selector_layout.setHorizontalSpacing(6)
        selector_layout.setVerticalSpacing(6)

        self.start_fret_spin = QSpinBox()
        self.start_fret_spin.setRange(0, self.current_max_fret)
        self.start_fret_spin.setValue(0)
        self.start_fret_spin.valueChanged.connect(self._update_output)

        self.end_fret_spin = QSpinBox()
        self.end_fret_spin.setRange(0, self.current_max_fret)
        self.end_fret_spin.setValue(24)
        self.end_fret_spin.valueChanged.connect(self._update_output)

        self.high_string_spin = QSpinBox()
        self.high_string_spin.valueChanged.connect(self._update_output)

        self.low_string_spin = QSpinBox()
        self.low_string_spin.valueChanged.connect(self._update_output)

        self.max_fret_spin = QSpinBox()
        self.max_fret_spin.setRange(12, 24)
        self.max_fret_spin.setValue(24)
        self.max_fret_spin.valueChanged.connect(self._max_fret_changed)

        selector_layout.addWidget(QLabel("Start Fret"), 0, 0)
        selector_layout.addWidget(self.start_fret_spin, 0, 1)
        selector_layout.addWidget(QLabel("End Fret"), 1, 0)
        selector_layout.addWidget(self.end_fret_spin, 1, 1)
        selector_layout.addWidget(QLabel("High String"), 2, 0)
        selector_layout.addWidget(self.high_string_spin, 2, 1)
        selector_layout.addWidget(QLabel("Low String"), 3, 0)
        selector_layout.addWidget(self.low_string_spin, 3, 1)
        selector_layout.addWidget(QLabel("Max Fret"), 4, 0)
        selector_layout.addWidget(self.max_fret_spin, 4, 1)

        selector_box.setLayout(selector_layout)
        right_column.addWidget(selector_box)

        content_layout.addLayout(left_column, stretch=4)
        content_layout.addLayout(right_column, stretch=0)

        main_layout.addLayout(content_layout)

        self._instrument_changed()

        # Fit height to content without shrinking width
        self.adjustSize()
        self.resize(1200, self.sizeHint().height())
        self.setMinimumHeight(self.sizeHint().height())

    def _instrument_changed(self):
        instrument = self.instrument_combo.currentText()
        tunings = INSTRUMENTS[instrument]
        self.tuning_combo.blockSignals(True)
        self.tuning_combo.clear()
        self.tuning_combo.addItems(list(tunings.keys()))
        self.tuning_combo.blockSignals(False)

        self._apply_default_max_fret(instrument)
        self._sync_string_ranges()
        self._update_output()

    def _apply_default_max_fret(self, instrument):
        default_max = INSTRUMENT_DEFAULT_MAX_FRETS.get(instrument, 24)
        self.max_fret_spin.blockSignals(True)
        self.max_fret_spin.setValue(default_max)
        self.max_fret_spin.blockSignals(False)
        self._max_fret_changed(default_max)

    def _sync_string_ranges(self):
        instrument = self.instrument_combo.currentText()
        tuning_name = self.tuning_combo.currentText()
        tuning = INSTRUMENTS[instrument][tuning_name]
        string_count = len(tuning)

        self.high_string_spin.setRange(1, string_count)
        self.low_string_spin.setRange(1, string_count)

        self.high_string_spin.setValue(1)
        self.low_string_spin.setValue(string_count)

    def _max_fret_changed(self, value):
        self.current_max_fret = value

        self.start_fret_spin.setRange(0, value)
        self.end_fret_spin.setRange(0, value)

        if self.end_fret_spin.value() != value:
            self.end_fret_spin.setValue(value)
        if self.start_fret_spin.value() > self.end_fret_spin.value():
            self.start_fret_spin.setValue(self.end_fret_spin.value())

        self._update_output()

    def _copy_text(self):
        QApplication.clipboard().setText(self.text_display.toPlainText())

    def _save_text(self):
        path, _ = QFileDialog.getSaveFileName(self, "Save as TXT", "", "Text Files (*.txt)")
        if path:
            with open(path, "w", encoding="utf-8") as f:
                f.write(self.text_display.toPlainText())

    def _sync_note_selectors(self, scale_len):
        for idx, checkbox in enumerate(self.note_checkboxes, start=1):
            if idx <= scale_len:
                checkbox.setEnabled(True)
            else:
                checkbox.setChecked(False)
                checkbox.setEnabled(False)

    def _selected_scale_notes(self, scale_notes):
        selected = set()
        for idx, checkbox in enumerate(self.note_checkboxes, start=1):
            if not checkbox.isChecked():
                continue
            if idx <= len(scale_notes):
                selected.add(scale_notes[idx - 1])
        return selected

    def _note_degree_map(self, scale_notes):
        degree_map = {}
        for idx, note in enumerate(scale_notes, start=1):
            if idx <= len(INTERVAL_LABELS):
                degree_map[note] = INTERVAL_LABELS[idx - 1]
        return degree_map

    def _format_cell(self, display_mode, fret, note, degree_map):
        if display_mode == "Fret Number":
            return f"{fret:>3}"
        if display_mode == "Note":
            return f"{note:>3}"
        if display_mode == "Interval":
            return f"{degree_map.get(note, '1'):>3}"
        return f"{fret:>3}"

    def _build_fret_marker_line(self, start_fret, end_fret):
        parts = ["Fret:"]
        first_cell = True

        for fret in range(start_fret, end_fret + 1):
            cell_width = 2 if first_cell else 3
            if fret in FRET_MARKERS:
                parts.append(f"{fret:>{cell_width}}")
            else:
                parts.append(" " * cell_width)
            first_cell = False

        return "".join(parts)

    def _update_output(self, *args):
        key = self.key_combo.currentText()
        scale_name = self.scale_combo.currentText()
        instrument = self.instrument_combo.currentText()
        tuning_name = self.tuning_combo.currentText()
        display_mode = self.display_mode_combo.currentText()

        start_fret = min(self.start_fret_spin.value(), self.end_fret_spin.value())
        end_fret = max(self.start_fret_spin.value(), self.end_fret_spin.value())
        high_string = min(self.high_string_spin.value(), self.low_string_spin.value())
        low_string = max(self.high_string_spin.value(), self.low_string_spin.value())

        self.fret_range_label.setText(f"Fret Range: {start_fret} - {end_fret}")

        scale_notes = self._build_scale_notes(key, scale_name)
        self._sync_note_selectors(len(scale_notes))
        active_notes = self._selected_scale_notes(scale_notes)
        degree_map = self._note_degree_map(scale_notes)

        tuning = INSTRUMENTS[instrument][tuning_name]  # low to high
        tuning_display = list(reversed(tuning))  # high to low for display

        string_indices = list(range(1, len(tuning) + 1))
        display_indices = [i for i in string_indices if high_string <= i <= low_string]

        lines = []
        header = f"{key} {scale_name} | {instrument}: {tuning_name} | Frets {start_fret}-{end_fret}"
        fret_line = self._build_fret_marker_line(start_fret, end_fret)
        divider = "-" * max(len(header), len(fret_line))

        lines.append(header)
        lines.append(fret_line)
        lines.append(divider)

        for idx in display_indices:
            string_note = tuning_display[idx - 1]
            open_index = NOTES_SHARP.index(string_note)
            line = [f"{string_note:>2} |"]
            for fret in range(start_fret, end_fret + 1):
                note = NOTES_SHARP[(open_index + fret) % 12]
                if note in active_notes:
                    cell = self._format_cell(display_mode, fret, note, degree_map)
                else:
                    cell = " --"
                line.append(cell)
            lines.append("".join(line))

        self.text_display.setPlainText("\n".join(lines))

    def _build_scale_notes(self, key, scale_name):
        root_idx = NOTES_SHARP.index(key)
        intervals = SCALE_INTERVALS[scale_name]
        return [NOTES_SHARP[(root_idx + i) % 12] for i in intervals]


def apply_dark_theme(app):
    app.setStyle("Fusion")

    palette = QPalette()
    palette.setColor(QPalette.ColorRole.Window, QColor("#202020"))
    palette.setColor(QPalette.ColorRole.WindowText, QColor("#CC7033"))
    palette.setColor(QPalette.ColorRole.Base, QColor("#202020"))
    palette.setColor(QPalette.ColorRole.AlternateBase, QColor("#202020"))
    palette.setColor(QPalette.ColorRole.Text, QColor("#CC7033"))
    palette.setColor(QPalette.ColorRole.Button, QColor("#202020"))
    palette.setColor(QPalette.ColorRole.ButtonText, QColor("#CC7033"))
    palette.setColor(QPalette.ColorRole.Highlight, QColor("#303030"))
    palette.setColor(QPalette.ColorRole.HighlightedText, QColor("#CC7033"))
    app.setPalette(palette)


def main():
    app = QApplication(sys.argv)
    apply_dark_theme(app)
    window = GuitarScaleApp()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
