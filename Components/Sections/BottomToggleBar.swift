import SwiftUI

// DisplayMode 是 BottomToggleBar 的模式枚举，未来可能被其他组件或界面层共用
enum DisplayMode {
    case courses  // 课程模式（当前显示课程）
    case events   // 事项模式（当前显示事项）
}

// BottomToggleBar 本身不持有 mode 状态，状态由父级界面层管理（单向数据流）
// 点击长条触发 onToggle 回调，由界面层修改实际 mode；组件内部包裹了 withAnimation 以保证动画播放
// 圆形+按钮仅在 events 模式下出现，通过条件渲染（不是 hidden）实现
struct BottomToggleBar: View {
    /// 当前显示模式
    let mode: DisplayMode

    /// 长条按钮点击回调（切换模式）
    let onToggle: () -> Void

    /// 圆形+按钮点击回调（跳转添加事项界面）
    let onAdd: () -> Void

    var body: some View {
        ZStack {
            // Bar 作为独立 Button，保留原生按压动画；label 内不放任何可交互子视图
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onToggle()
                }
            }) {
                RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                    .fill(mode == .events ? EventCardColors.eventTint : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius)
                            .strokeBorder(
                                EventCardColors.eventTint,
                                lineWidth: mode == .courses ? AppSpacing.borderThin : 0
                            )
                    )
                    .overlay(
                        Text(mode == .courses ? "切换至事项" : "切换至课程")
                            .font(AppFonts.bodyMedium)
                            .foregroundColor(
                                mode == .courses ? EventCardColors.eventTint : TextColors.textOnHighlight
                            )
                    )
            }
            .frame(width: 334, height: 52)

            // Plus 按钮在 ZStack 上层，hit-test 优先于 Button；
            // Spacer 区域无交互，点击穿透给下方 Button
            if mode == .events {
                HStack {
                    Spacer()
                    CircleIconButton(icon: "plus", action: onAdd)
                        .padding(.trailing, AppSpacing.columnSpacing)
                }
                .frame(width: 334)
            }
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        Text("课程模式").font(.caption)
        BottomToggleBar(
            mode: .courses,
            onToggle: { print("toggle tapped") },
            onAdd: { print("add tapped") }
        )

        Text("事项模式").font(.caption)
        BottomToggleBar(
            mode: .events,
            onToggle: { print("toggle tapped") },
            onAdd: { print("add tapped") }
        )
    }
    .padding(32)
    .background(Color.gray.opacity(0.08))
}
