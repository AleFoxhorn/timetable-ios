import SwiftUI

struct DateCell: View {
    /// 星期缩写，例如 "SAT"
    let weekday: String

    /// 日期数字，例如 29
    let day: Int

    /// 是否为今天
    let isToday: Bool

    private var backgroundColor: Color {
        isToday ? AppColors.todayHighlight : .white
    }

    private var textColor: Color {
        isToday ? TextColors.textOnHighlight : TextColors.textPrimary
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(weekday)
                .font(AppFonts.caption)
                .foregroundColor(textColor)

            Spacer(minLength: 0)

            Text("\(day)")
                .font(AppFonts.captionBold)
                .foregroundColor(textColor)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            if !isToday {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(AppColors.borderPrimary, lineWidth: AppSpacing.borderThin)
            }
        }
    }
}

#Preview {
    HStack(alignment: .top, spacing: AppSpacing.columnSpacing) {
        DateCell(weekday: "SAT", day: 29, isToday: false)
            .frame(maxWidth: .infinity).frame(height: 35)

        DateCell(weekday: "SUN", day: 30, isToday: false)
            .frame(maxWidth: .infinity).frame(height: 35)

        DateCell(weekday: "MON", day: 1, isToday: false)
            .frame(maxWidth: .infinity).frame(height: 35)

        DateCell(weekday: "TUE", day: 2, isToday: true)
            .frame(maxWidth: .infinity).frame(height: 35)

        DateCell(weekday: "WED", day: 3, isToday: false)
            .frame(maxWidth: .infinity).frame(height: 35)

        DateCell(weekday: "THU", day: 4, isToday: false)
            .frame(maxWidth: .infinity).frame(height: 35)

        DateCell(weekday: "FRI", day: 5, isToday: false)
            .frame(maxWidth: .infinity).frame(height: 35)
    }
    .frame(width: AppSpacing.courseGridWidth)
    .padding(32)
    .background(Color.gray.opacity(0.08))
}
