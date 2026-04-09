import SwiftUI

struct FretboardOutputView: View {
    let text: String

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            Text(text)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(Color("AccentAmber"))
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color("FretboardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color("AccentAmber").opacity(0.3), lineWidth: 1)
        )
        .frame(minHeight: 180)
    }
}

#Preview {
    FretboardOutputView(text: """
    E Major | Guitar: Standard (EADGBE) | Frets 0-12
    Fret: 0  3  5  7  9 12
    ------------------------------------------
     E |  0 --  4 --  7 --  11
     B |  0 --  4 --  7 --  11
     G |  0 --  4  5  7 --  11
     D |  0  2 --  5 --  9  --
     A |  0 --  4 --  7 --  11
     E |  0 --  4 --  7 --  11
    """)
    .padding()
    .background(Color("AppBackground"))
    .preferredColorScheme(.dark)
}
