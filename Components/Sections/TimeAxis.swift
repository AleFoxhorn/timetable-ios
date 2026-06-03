import SwiftUI

struct TimeAxis: View {
    /// 11 节课的开始时间，固定 11 个元素，与节次编号一一对应
    let times: [String]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(times.enumerated()), id: \.offset) { index, time in
                TimeAxisCell(time: time, number: index + 1)
                    .frame(width: AppSpacing.timeAxisWidth, height: AppSpacing.cellHeight)
                    .padding(.bottom, bottomSpacing(after: index))
            }
        }
    }

    // 每组 4 个 cell 密集排列，组间用隔离间距
    private func bottomSpacing(after index: Int) -> CGFloat {
        guard index < times.count - 1 else { return 0 }
        return (index + 1) % 4 == 0 ? AppSpacing.rowSpacingIsolated : AppSpacing.rowSpacingDense
    }
}

#Preview {
    TimeAxis(times: [
        "08:00", "08:50", "10:05", "10:55",
        "11:15", "13:30", "14:20", "15:35",
        "16:25", "18:00", "18:55"
    ])
    .padding(32)
    .background(Color.gray.opacity(0.08))
}
