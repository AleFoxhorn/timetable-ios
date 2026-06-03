import SwiftUI

// 默认背景为 .ultraThinMaterial（iOS 原生毛玻璃材质）
// 毛玻璃效果在彩色背景上最显著，在纯白背景上视觉较淡（这是材质特性，非 bug）
// 如需自定义背景（纯色、其他材质等），通过 background: AnyShapeStyle(...) 传入
struct CircleIconButton: View {
    /// SF Symbol 图标名称
    let icon: String

    /// 点击按钮时执行的回调
    let action: () -> Void

    /// 按钮直径，默认 44
    var size: CGFloat = 44

    /// 图标颜色，默认使用主色
    var iconColor: Color = .primary

    /// 圆形背景填充，默认毛玻璃材质；如需自定义传入 AnyShapeStyle(...)
    var background: AnyShapeStyle = AnyShapeStyle(.ultraThinMaterial)

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: size, height: size)
                .background(background, in: Circle())
                .overlay(
                    Circle().strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: AppSpacing.borderThin
                    )
                )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        CircleIconButton(
            icon: "plus",
            action: { print("tapped") }
        )

        CircleIconButton(
            icon: "doc.badge.plus",
            action: { print("tapped") }
        )

        CircleIconButton(
            icon: "plus",
            action: { print("tapped") },
            iconColor: .purple
        )

        CircleIconButton(
            icon: "heart.fill",
            action: { print("tapped") },
            background: AnyShapeStyle(Color.white.opacity(0.4))
        )
    }
    .padding(32)
    .background(
        LinearGradient(
            colors: [.purple, .indigo, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
}
