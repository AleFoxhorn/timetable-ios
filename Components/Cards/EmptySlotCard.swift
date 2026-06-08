import SwiftUI

struct EmptySlotCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.white)
    }
}

#Preview {
    let w: CGFloat = (318 - 6 * 4) / 7
    let h: CGFloat = 47

    HStack(alignment: .top, spacing: 4) {
        ForEach(0..<4) { _ in
            EmptySlotCard().frame(width: w, height: h)
        }
    }
    .padding(24)
    .background(Color.black)
}
