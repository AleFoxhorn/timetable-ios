import SwiftUI

struct DayInfo {
    let weekday: String
    let day: Int
    let isToday: Bool
}

struct WeekDateBar: View {
    /// 月份标签，支持换行，如 "五\n月"
    let month: String

    /// 一周 7 天数据，固定 7 个元素
    let days: [DayInfo]

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // 月份标签弹性填满 TimeAxis 所占的剩余空间，内容水平居中
            Text(month)
                .font(.custom("MiSans-Medium", size: 15))
                .tracking(-1.31)
                .foregroundColor(AppColors.textOnDark)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            // 日期格固定 321pt，与右侧主要区域宽度一致
            HStack(spacing: 1) {
                ForEach(Array(days.enumerated()), id: \.offset) { _, info in
                    DateCell(weekday: info.weekday, day: info.day, isToday: info.isToday)
                }
            }
            .frame(width: 321)
        }
        // 不设固定外框，由父层施加 trailing padding 控制右端位置
    }
}

#Preview {
    WeekDateBar(
        month: "五\n月",
        days: [
            DayInfo(weekday: "SAT", day: 23, isToday: false),
            DayInfo(weekday: "SUN", day: 24, isToday: false),
            DayInfo(weekday: "MON", day: 25, isToday: false),
            DayInfo(weekday: "THU", day: 26, isToday: true),
            DayInfo(weekday: "WED", day: 27, isToday: false),
            DayInfo(weekday: "THU", day: 28, isToday: false),
            DayInfo(weekday: "FRI", day: 29, isToday: false)
        ]
    )
    .padding(32)
    .background(Color.black)
}
