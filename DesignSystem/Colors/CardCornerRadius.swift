import SwiftUI

// 允许通过 .environment(\.cardCornerRadius, value) 在视图树任意层覆盖所有卡片圆角
// 默认值回退到 AppSpacing.cardCornerRadius，不注入时行为与原来完全一致

private struct CardCornerRadiusKey: EnvironmentKey {
    static let defaultValue: CGFloat = AppSpacing.cardCornerRadius
}

extension EnvironmentValues {
    var cardCornerRadius: CGFloat {
        get { self[CardCornerRadiusKey.self] }
        set { self[CardCornerRadiusKey.self] = newValue }
    }
}
