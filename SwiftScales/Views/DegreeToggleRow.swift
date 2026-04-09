import SwiftUI

struct DegreeToggleRow: View {
    @Binding var activeDegrees: [Bool]
    let enabled: [Bool]

    private let labels = romanLabels

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Degrees")
                .font(.caption)
                .foregroundStyle(Color("AccentAmber").opacity(0.7))

            HStack(spacing: 6) {
                ForEach(0..<labels.count, id: \.self) { index in
                    Button(action: {
                        if enabled[index] {
                            activeDegrees[index].toggle()
                        }
                    }) {
                        Text(labels[index])
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .frame(minWidth: 32, minHeight: 28)
                            .foregroundStyle(
                                buttonForeground(index: index)
                            )
                            .background(
                                buttonBackground(index: index)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        buttonBorder(index: index),
                                        lineWidth: 1
                                    )
                            )
                    }
                    .disabled(!enabled[index])
                }
                Spacer()
            }
        }
    }

    private func buttonForeground(index: Int) -> Color {
        guard enabled[index] else { return Color("AccentAmber").opacity(0.25) }
        return activeDegrees[index] ? Color("AppBackground") : Color("AccentAmber")
    }

    private func buttonBackground(index: Int) -> Color {
        guard enabled[index] && activeDegrees[index] else { return .clear }
        return Color("AccentAmber")
    }

    private func buttonBorder(index: Int) -> Color {
        guard enabled[index] else { return Color("AccentAmber").opacity(0.2) }
        return Color("AccentAmber")
    }
}

#Preview {
    DegreeToggleRow(
        activeDegrees: .constant([true, true, true, false, true, false, false]),
        enabled: [true, true, true, true, true, false, false]
    )
    .padding()
    .background(Color("AppBackground"))
    .preferredColorScheme(.dark)
}
