import SwiftUI

/// 无课时段的占位卡片
struct EmptySlotCard: View {
    @Environment(\.cardCornerRadius) private var cardCornerRadius

    var body: some View {
        RoundedRectangle(cornerRadius: cardCornerRadius)
            .fill(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .stroke(AppColors.borderSubtle, lineWidth: AppSpacing.borderUltraThin)
            )
    }
}

#Preview {
    let cardWidth = (AppSpacing.courseGridWidth - 6 * AppSpacing.columnSpacing) / 7

    VStack(alignment: .leading, spacing: 20) {
        EmptySlotCard()
            .frame(width: cardWidth, height: AppSpacing.cellHeight)

        HStack(spacing: AppSpacing.columnSpacing) {
            EmptySlotCard()
            EmptySlotCard()
            EmptySlotCard()
        }
        .frame(width: cardWidth * 3 + AppSpacing.columnSpacing * 2, height: AppSpacing.cellHeight, alignment: .leading)
    }
    .frame(width: AppSpacing.courseGridWidth, alignment: .leading)
    .padding(24)
    .background(Color.gray.opacity(0.08))
}
