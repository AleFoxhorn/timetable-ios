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
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    onToggle()
                }
            }) {
                ZStack {
                    if mode == .courses {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(AppColors.eventOverlay35)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(AppColors.eventAccent, lineWidth: 1.4)
                            )

                        Text("切换到事项")
                            .font(.custom("MiSans-Medium", size: 18))
                            .foregroundColor(AppColors.textOnDark)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(AppColors.eventAccent)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(AppColors.eventAccent, lineWidth: 1)
                            )

                        Text("切换到课程")
                            .font(.custom("MiSans-Medium", size: 18))
                            .foregroundColor(AppColors.textPrimary)
                    }
                }
            }
            .frame(width: 321, height: 55)
            .buttonStyle(.plain)

            if mode == .events {
                HStack {
                    Spacer()
                    Button(action: onAdd) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(AppColors.surfacePrimary)
                            .frame(width: 31, height: 31)
                            .overlay {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(AppColors.textPrimary)
                                        .frame(width: 2.714, height: 19)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(AppColors.textPrimary)
                                        .frame(width: 19, height: 2.714)
                                }
                            }
                    }
                    .buttonStyle(.plain)
                        .padding(.trailing, 12)
                }
                .frame(width: 321)
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
