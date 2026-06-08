import SwiftUI

/// 上课周选择区（第1周～第N周）
/// 6列网格，水平间距1，垂直间距2，固定宽287
struct CycleSelectionSection: View {
    let total: Int                    // 总周数，通常为20
    @Binding var selected: Set<Int>   // 已选周数（1-based）

    private let cols:  Int     = 6
    private let cellW: CGFloat = 47
    private let cellH: CGFloat = 39
    private let hGap:  CGFloat = 1
    private let vGap:  CGFloat = 2

    @State private var dragAnchor:   Int?     = nil
    @State private var dragBaseline: Set<Int> = []

    private var width: CGFloat { CGFloat(cols) * cellW + CGFloat(cols - 1) * hGap }

    var body: some View {
        VStack(alignment: .leading, spacing: vGap) {
            ForEach(0..<rowCount, id: \.self) { row in
                HStack(spacing: hGap) {
                    ForEach(0..<cellsInRow(row), id: \.self) { col in
                        let n = row * cols + col + 1
                        CycleSelection(number: n, isSelected: selected.contains(n))
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
                    let adding = !dragBaseline.contains(lo + 1)
                    var next = dragBaseline
                    for i in lo...hi {
                        let n = i + 1
                        if n >= 1 && n <= total { if adding { next.insert(n) } else { next.remove(n) } }
                    }
                    selected = next
                }
                .onEnded { v in
                    let isTap = abs(v.translation.width) < 4 && abs(v.translation.height) < 4
                    if isTap, let idx = cellIndex(at: v.startLocation) {
                        let n = idx + 1
                        if selected.contains(n) { selected.remove(n) } else { selected.insert(n) }
                    }
                    dragAnchor   = nil
                    dragBaseline = []
                }
        )
    }

    private var rowCount: Int { (total + cols - 1) / cols }
    private func cellsInRow(_ r: Int) -> Int { min(cols, total - r * cols) }

    private func cellIndex(at p: CGPoint) -> Int? {
        let col = Int(p.x / (cellW + hGap))
        let row = Int(p.y / (cellH + vGap))
        let idx = row * cols + col
        guard col >= 0, col < cols, idx >= 0, idx < total else { return nil }
        return idx
    }
}

#Preview {
    @Previewable @State var selected: Set<Int> = [1, 2, 3, 4, 5, 6, 7, 8]
    CycleSelectionSection(total: 20, selected: $selected)
        .padding(24)
        .background(Color.black)
}
