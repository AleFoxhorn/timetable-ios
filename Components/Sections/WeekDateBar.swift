import SwiftUI

/// 单日日期数据
struct DayInfo {
    let weekday: String  // 星期缩写，如 "SAT"
    let day: Int         // 日期数字，如 29
    let isToday: Bool    // 是否为今天
}

struct WeekDateBar: View {
    /// 月份缩写，如 "May"
    let month: String

    /// 一周 7 天的数据，固定 7 个元素
    let days: [DayInfo]

    var body: some View {
        HStack(spacing: 0) {
            // 左侧月份标签，固定 64pt
            Text(month)
                .font(AppFonts.bodyMedium)
                .foregroundColor(TextColors.textPrimary)
                .frame(width: 64)

            // 右侧 7 个 DateCell，在 318pt 内等分
            HStack(alignment: .top, spacing: AppSpacing.columnSpacing) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, info in
                    DateCell(weekday: info.weekday, day: info.day, isToday: info.isToday)
                        .frame(maxWidth: .infinity).frame(height: 35)
                }
            }
            .frame(width: AppSpacing.courseGridWidth)
        }
    }
}

#Preview {
    WeekDateBar(
        month: "May",
        days: [
            DayInfo(weekday: "SAT", day: 23, isToday: false),
            DayInfo(weekday: "SUN", day: 24, isToday: false),
            DayInfo(weekday: "MON", day: 25, isToday: true),
            DayInfo(weekday: "TUE", day: 26, isToday: false),
            DayInfo(weekday: "WED", day: 27, isToday: false),
            DayInfo(weekday: "THU", day: 28, isToday: false),
            DayInfo(weekday: "FRI", day: 29, isToday: false)
        ]
    )
    .padding(32)
    .background(Color.gray.opacity(0.08))
}
