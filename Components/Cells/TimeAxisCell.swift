import SwiftUI

struct TimeAxisCell: View {
    /// 节次开始时间，例如 "08:00"
    let time: String

    /// 节次编号，例如 1
    let number: Int

    var body: some View {
        ZStack {
            Text("\(number)")
                .font(AppFonts.captionBold)
                .foregroundColor(TextColors.textPrimary)

            VStack(spacing: 0) {
                Text(time)
                    .font(AppFonts.caption)
                    .foregroundColor(TextColors.textSecondary)

                Spacer(minLength: 0)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                .stroke(AppColors.borderSubtle, lineWidth: AppSpacing.borderUltraThin)
        )
    }
}

#Preview {
    HStack(spacing: 0) {
        TimeAxisCell(time: "08:00", number: 1)
            .frame(width: AppSpacing.timeAxisWidth, height: AppSpacing.cellHeight)

        TimeAxisCell(time: "10:05", number: 3)
            .frame(width: AppSpacing.timeAxisWidth, height: AppSpacing.cellHeight)

        TimeAxisCell(time: "13:30", number: 5)
            .frame(width: AppSpacing.timeAxisWidth, height: AppSpacing.cellHeight)
    }
    .padding(32)
    .background(Color.gray.opacity(0.08))
}
