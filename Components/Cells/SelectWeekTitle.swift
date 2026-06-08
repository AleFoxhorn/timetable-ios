import SwiftUI

struct SelectWeekTitle: View {
    enum Style {
        case empty
        case filled
        case numbered(Int)
    }

    let style: Style

    private var displayText: String {
        switch style {
        case .empty:
            return "…"
        case .filled:
            return "本周"
        case .numbered(let value):
            return "\(value)"
        }
    }

    private var background: Color {
        switch style {
        case .filled:
            return AppColors.semesterWeekRowHighlight
        case .empty, .numbered:
            return AppColors.semesterWeekRow
        }
    }

    var body: some View {
        Text(displayText)
            .font(AppFonts.semesterWeekLabel)
            .foregroundColor(AppColors.weekLabelText)
            .multilineTextAlignment(.center)
            .frame(width: 37, height: 47)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: CardCornerRadius.large))
    }
}

#Preview {
    HStack(spacing: 8) {
        SelectWeekTitle(style: .empty)
        SelectWeekTitle(style: .numbered(8))
        SelectWeekTitle(style: .filled)
    }
    .padding(24)
    .background(Color.black)
}
