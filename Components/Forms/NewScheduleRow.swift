import SwiftUI

// MARK: - NewScheduleRow
// Figma: 交互设计2.0 › newschedule 组件集（node 9:574）
// 六种变体：Property 1=1 到 Property 1=6

struct NewScheduleRow: View {

    // MARK: - 变体（六种，与 Figma 一一对应）

    enum Variant {
        /// Property 1=1 — 文字输入行，下圆角（顶部 flat r=2，底部 r=15）
        case v1_textFieldBottom(label: String, placeholder: String)

        /// Property 1=2 — 文字输入行，全圆角（r=15，独立/中间行）
        case v2_textFieldRound(label: String, placeholder: String)

        /// Property 1=3 — 文字输入行，上圆角（顶部 r=15，底部 flat r=2）
        case v3_textFieldTop(label: String, placeholder: String)

        /// Property 1=4 — 选择器行，全圆角（r=15，独立/中间行）
        case v4_pickerRound(label: String, selectedValue: String?)

        /// Property 1=5 — 备注输入区域，上圆角（高度 83pt，双行布局）
        case v5_notesTop(label: String, placeholder: String)

        /// Property 1=6 — 选择器行，上圆角（顶部 r=15，底部 flat r=2）
        case v6_pickerTop(label: String, selectedValue: String?)
    }

    let variant: Variant

    /// 点击行时触发，后续对接跳转/输入逻辑
    let onTap: () -> Void

    // MARK: - Layout helpers

    // 圆角值：(topLeading, topTrailing, bottomLeading, bottomTrailing)
    private var corners: (tl: CGFloat, tr: CGFloat, bl: CGFloat, br: CGFloat) {
        switch variant {
        case .v1_textFieldBottom:
            return (2, 2, 15, 15)     // Figma: 2px 2px 15px 15px
        case .v2_textFieldRound, .v4_pickerRound:
            return (15, 15, 15, 15)   // Figma: 15px
        case .v3_textFieldTop, .v5_notesTop, .v6_pickerTop:
            return (15, 15, 2, 2)     // Figma: 15px 15px 2px 2px
        }
    }

    private var rowHeight: CGFloat {
        if case .v5_notesTop = variant { return 83 }
        return 65
    }

    // MARK: - Body

    var body: some View {
        rowContent
            .frame(maxWidth: .infinity)
            .frame(height: rowHeight)
            .background(Color.white)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: corners.tl,
                    bottomLeadingRadius: corners.bl,
                    bottomTrailingRadius: corners.br,
                    topTrailingRadius: corners.tr
                )
            )
            .contentShape(Rectangle())
            .onTapGesture { onTap() }
    }

    // MARK: - 内容分发

    @ViewBuilder
    private var rowContent: some View {
        switch variant {
        case .v1_textFieldBottom(let label, let placeholder):
            textFieldContent(label: label, placeholder: placeholder)
        case .v2_textFieldRound(let label, let placeholder):
            textFieldContent(label: label, placeholder: placeholder)
        case .v3_textFieldTop(let label, let placeholder):
            textFieldContent(label: label, placeholder: placeholder)
        case .v4_pickerRound(let label, let selected):
            pickerContent(label: label, selectedValue: selected)
        case .v5_notesTop(let label, let placeholder):
            notesContent(label: label, placeholder: placeholder)
        case .v6_pickerTop(let label, let selected):
            pickerContent(label: label, selectedValue: selected)
        }
    }

    // MARK: - 内容构建器

    /// 变体 1 / 2 / 3：「标签 ← 占位文字」横排
    @ViewBuilder
    private func textFieldContent(label: String, placeholder: String) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
            Spacer()
            Text(placeholder)
                .font(Font.custom("MiSans-Regular", size: 16))
                .foregroundColor(.black)
        }
        .padding(.leading, 37)
        .padding(.trailing, 36)
    }

    /// 变体 4 / 6：「标签 ← 已选值 + 下拉三角」横排
    @ViewBuilder
    private func pickerContent(label: String, selectedValue: String?) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
            Spacer()
            // Figma openfolder 实例：文字 + Polygon 5（下拉三角）
            HStack(alignment: .bottom, spacing: 3) {
                Text(selectedValue ?? "未选择")
                    .font(Font.custom("MiSans-Regular", size: 16))
                    .foregroundColor(.black)
                Image(systemName: "arrowtriangle.down.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.black)
            }
        }
        .padding(.leading, 37)
        .padding(.trailing, 36)
    }

    /// 变体 5：「标签」+「占位文字」纵排
    @ViewBuilder
    private func notesContent(label: String, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
            Text(placeholder)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 37)
        .padding(.trailing, 36)
    }
}

// MARK: - Preview（六种变体一览）
#Preview {
    ScrollView {
        VStack(spacing: 16) {

            // Property 1=1：文字输入行，下圆角
            NewScheduleRow(
                variant: .v1_textFieldBottom(label: "课程地点", placeholder: "输入课程地点"),
                onTap: { print("v1 tapped") }
            )

            // Property 1=2：文字输入行，全圆角
            NewScheduleRow(
                variant: .v2_textFieldRound(label: "课程地点", placeholder: "输入课程地点"),
                onTap: { print("v2 tapped") }
            )

            // Property 1=3：文字输入行，上圆角
            NewScheduleRow(
                variant: .v3_textFieldTop(label: "课程地点", placeholder: "输入课程地点"),
                onTap: { print("v3 tapped") }
            )

            // Property 1=4：选择器行，全圆角
            NewScheduleRow(
                variant: .v4_pickerRound(label: "课程地点", selectedValue: nil),
                onTap: { print("v4 tapped") }
            )

            // Property 1=5：备注区域，上圆角
            NewScheduleRow(
                variant: .v5_notesTop(label: "事项备注：", placeholder: "……"),
                onTap: { print("v5 tapped") }
            )

            // Property 1=6：选择器行，上圆角
            NewScheduleRow(
                variant: .v6_pickerTop(label: "课程地点", selectedValue: nil),
                onTap: { print("v6 tapped") }
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
    }
    .background(Color.black)
}
