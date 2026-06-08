import SwiftUI

struct EventDateInfo {
    let weekday: String   // e.g. "WED"
    let day: Int          // e.g. 25
}

/// 事项日期选择区（单行7天，含星期+日期数字）
/// 单行，水平间距1，宽度自适应（7 × 47 + 6 × 1 = 335）
struct EventSelectionSection: View {
    let dates: [EventDateInfo]          // 7个日期，按顺序
    @Binding var selected: Set<Int>     // 已选索引（0-based）

    private let cellW: CGFloat = 47
    private let cellH: CGFloat = 39
    private let hGap:  CGFloat = 1

    @State private var dragAnchor:   Int?     = nil
    @State private var dragBaseline: Set<Int> = []

    var body: some View {
        HStack(spacing: hGap) {
            ForEach(Array(dates.enumerated()), id: \.offset) { idx, item in
                EventDateSelection(
                    weekday: item.weekday,
                    day: item.day,
                    isSelected: selected.contains(idx)
                )
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { v in
                    if dragAnchor == nil {
                        guard abs(v.translation.width) >= 4 || abs(v.translation.height) >= 4 else { return }
                        guard let startIdx = cellIndex(at: v.startLocation) else { return }
                        dragAnchor   = startIdx
                        dragBaseline = selected
                    }
                    guard let anchor = dragAnchor, let cur = cellIndex(at: v.location) else { return }
                    let lo = min(anchor, cur), hi = max(anchor, cur)
                    let adding = !dragBaseline.contains(lo)
                    var next = dragBaseline
                    for i in lo...hi where i < dates.count {
                        if adding { next.insert(i) } else { next.remove(i) }
                    }
                    selected = next
                }
                .onEnded { v in
                    let isTap = abs(v.translation.width) < 4 && abs(v.translation.height) < 4
                    if isTap, let idx = cellIndex(at: v.startLocation) {
                        if selected.contains(idx) { selected.remove(idx) } else { selected.insert(idx) }
                    }
                    dragAnchor   = nil
                    dragBaseline = []
                }
        )
    }

    private func cellIndex(at p: CGPoint) -> Int? {
        let idx = Int(p.x / (cellW + hGap))
        guard idx >= 0, idx < dates.count else { return nil }
        return idx
    }
}

#Preview {
    @Previewable @State var selected: Set<Int> = [3]
    let sampleDates: [EventDateInfo] = [
        EventDateInfo(weekday: "MON", day: 23),
        EventDateInfo(weekday: "TUE", day: 24),
        EventDateInfo(weekday: "WED", day: 25),
        EventDateInfo(weekday: "THU", day: 26),
        EventDateInfo(weekday: "FRI", day: 27),
        EventDateInfo(weekday: "SAT", day: 28),
        EventDateInfo(weekday: "SUN", day: 29),
    ]
    EventSelectionSection(dates: sampleDates, selected: $selected)
        .padding(24)
        .background(Color.black)
}
