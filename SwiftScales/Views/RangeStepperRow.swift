import SwiftUI

/// A labeled pair of steppers for a low/high range (e.g. fret range or string range).
struct RangeStepperRow: View {
    let label: String
    let lowLabel: String
    let highLabel: String
    @Binding var lowValue: Int
    @Binding var highValue: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("AccentAmber").opacity(0.7))

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Text(lowLabel)
                        .font(.caption)
                        .foregroundStyle(Color("AccentAmber"))
                    Stepper(
                        value: $lowValue,
                        in: range.lowerBound...min(highValue, range.upperBound)
                    ) {
                        Text("\(lowValue)")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(Color("AccentAmber"))
                            .frame(minWidth: 24, alignment: .trailing)
                    }
                    .tint(Color("AccentAmber"))
                }

                HStack(spacing: 6) {
                    Text(highLabel)
                        .font(.caption)
                        .foregroundStyle(Color("AccentAmber"))
                    Stepper(
                        value: $highValue,
                        in: max(lowValue, range.lowerBound)...range.upperBound
                    ) {
                        Text("\(highValue)")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundStyle(Color("AccentAmber"))
                            .frame(minWidth: 24, alignment: .trailing)
                    }
                    .tint(Color("AccentAmber"))
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var low = 0
    @Previewable @State var high = 12

    RangeStepperRow(
        label: "Frets",
        lowLabel: "Start",
        highLabel: "End",
        lowValue: $low,
        highValue: $high,
        range: 0...24
    )
    .padding()
    .background(Color("AppBackground"))
    .preferredColorScheme(.dark)
}
