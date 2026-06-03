import SwiftUI

struct TopHeader: View {
    /// 周数标题，如 "第十周"
    let weekTitle: String

    /// 左按钮（新建课表）回调
    let onNewSchedule: () -> Void

    /// 右按钮（添加项目）回调
    let onAddItem: () -> Void

    var body: some View {
        // 标题通过 ZStack 相对父容器居中，与两侧按钮宽度无关
        ZStack {
            Text(weekTitle)
                .font(AppFonts.titleLarge)
                .foregroundColor(TextColors.textPrimary)

            // 按钮图标固定（左 doc.badge.plus、右 plus），如需更换在此修改
            HStack {
                CircleIconButton(icon: "doc.badge.plus", action: onNewSchedule)
                Spacer()
                CircleIconButton(icon: "plus", action: onAddItem)
            }
            .padding(.horizontal, AppSpacing.screenPaddingHorizontal)
        }
        // 组件高度由内容自然决定，上下间距由外层界面控制
    }
}

#Preview {
    TopHeader(
        weekTitle: "第十周",
        onNewSchedule: { print("新建课表 tapped") },
        onAddItem: { print("添加 tapped") }
    )
    .padding(16)
    .background(Color.gray.opacity(0.08))
}
