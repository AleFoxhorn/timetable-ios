import SwiftUI

/// 上课星期选择区（MON～SUN，共7天）
/// 5列网格，水平间距1，垂直间距1，固定宽239
struct DateSelectionSection: View {
    @Binding var selected: Set<Int>   // 已选索引（0-based，0=MON … 6=SUN）

    private let weekdays: [String] = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    private let cols:  Int     = 5
    private let cellW: CGFloat = 47
    private let cellH: CGFloat = 39
    private let hGap:  CGFloat = 1
    private let vGap:  CGFloat = 1

    @State private var dragAnchor:   Int?     = nil
    @State private var dragBaseline: Set<Int> = []

    private var width: CGFloat { CGFloat(cols) * cellW + CGFloat(cols - 1) * hGap }

    var body: some View {
        VStack(alignment: .leading, spacing: vGap) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: hGap) {
                    ForEach(0..<cellsInRow(row), id: \.self) { col in
                        let idx = row * cols + col
                        DateSelection(weekday: weekdays[idx], isSelected: selected.contains(idx))
                    }
                }
            }
        }
        .frame(width: width)
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
                    for i in lo...hi where i < weekdays.count {
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

    private var rowCount: Int { (weekdays.count + cols - 1) / cols }
    private func cellsInRow(_ r: Int) -> Int { min(cols, weekdays.count - r * cols) }

    private func cellIndex(at p: CGPoint) -> Int? {
        let col = Int(p.x / (cellW + hGap))
        let row = Int(p.y / (cellH + vGap))
        let idx = row * cols + col
        guard col >= 0, col < cols, idx >= 0, idx < weekdays.count else { return nil }
        return idx
    }
}

#Preview {
    @Previewable @State var selected: Set<Int> = [1, 2]
    DateSelectionSection(selected: $selected)
        .padding(24)
        .background(Color.black)
}
