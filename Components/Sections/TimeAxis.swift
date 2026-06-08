import SwiftUI

struct TimeAxis: View {
    /// 每节课开始时间，index 0 = 第1节，依此类推
    let times: [String]

    /// 按每组4节拆分，保留原始 index 用于节次编号
    private var groups: [[(index: Int, time: String)]] {
        let indexed = times.enumerated().map { (index: $0.offset, time: $0.element) }
        return stride(from: 0, to: indexed.count, by: 4).map {
            Array(indexed[$0 ..< min($0 + 4, indexed.count)])
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            ForEach(Array(groups.enumerated()), id: \.offset) { _, group in
                VStack(spacing: 1) {
                    ForEach(group, id: \.index) { entry in
                        TimeAxisCell(time: entry.time, number: entry.index + 1)
                            .frame(width: 57, height: 47)
                    }
                }
            }
        }
        .frame(width: 57)
    }
}

#Preview {
    TimeAxis(times: [
        "08:00", "08:50", "10:05", "10:55",
        "13:30", "14:20", "15:35", "16:25",
        "18:00", "18:55", "19:50", "20:45"
    ])
    .padding(24)
    .background(Color.black)
}
