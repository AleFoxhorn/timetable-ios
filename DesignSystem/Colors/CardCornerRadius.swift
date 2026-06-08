import SwiftUI

enum CardCornerRadius {

    // MARK: - Core

    /// 大圆角卡片、周标签、周行常规圆角
    static let large: CGFloat = 15

    /// `selectweekrow` 顶部小圆角
    static let microTop: CGFloat = 2

    /// `CourseTaskPopover` 外层圆角
    static let taskPopoverOuter: CGFloat = 12

    /// `CourseTaskPopover` 内层圆角
    static let taskPopoverInner: CGFloat = 5

    /// `tasklistcell` 中间 pill 行圆角
    static let taskRowPill: CGFloat = 30

    /// 圆形图标按钮半径由组件自身按尺寸裁切，这里保留语义值供非圆裁切组件复用
    static let iconButtonCircle: CGFloat = 27
}
