import SwiftUI

// MARK: - 全局颜色令牌
// 来源：设计稿「交互设计2.0」16 个主界面实际使用颜色
enum AppColors {

    // MARK: 背景
    static let screenBackground = Color.black
    static let surfacePrimary = Color.white
    static let surfaceInverse = Color.black
    static let editorExpandedFill = Color(red: 0.643, green: 0.643, blue: 0.643)

    // MARK: 文字
    static let textPrimary    = Color.black
    /// 日期数字、周几标签等强调性黑色
    static let textStrong     = Color(red: 0.106, green: 0.110, blue: 0.098)   // #1B1C19
    /// 选中态文字／描边（深蓝灰）
    static let textActive     = Color(red: 0.122, green: 0.161, blue: 0.216)   // #1F2937
    /// 深色背景上的白色文字
    static let textOnDark     = Color.white
    /// 学周标签文本（`…` / `本周` / 周编号）
    static let weekLabelText  = Color.black.opacity(0.76)

    // MARK: 描边
    static let borderPrimary  = Color.black
    static let borderHeavy = Color.black

    // MARK: 课程卡片
    /// 正面背景（浅灰）
    static let courseCardFront     = Color(red: 0.847, green: 0.847, blue: 0.847)  // #D8D8D8
    /// 背面背景（深蓝）
    static let courseCardBack      = Color(red: 0.000, green: 0.137, blue: 0.831)  // #0023D4

    // MARK: 事项卡片 & 事项主题（荧光黄系）
    /// 事项卡正面背景 / BottomToggleBar 事项模式主色
    static let eventAccent         = Color(red: 0.816, green: 0.953, blue: 0.000)  // #D0F300
    /// 事项卡背面背景
    static let eventCardBackFill   = Color(red: 0.816, green: 0.953, blue: 0.000).opacity(0.25)
    /// 事项叠加层（透明度梯度）
    static let eventOverlay20      = Color(red: 0.816, green: 0.953, blue: 0.000).opacity(0.20)
    static let eventOverlay30      = Color(red: 0.816, green: 0.953, blue: 0.000).opacity(0.30)
    static let eventOverlay35      = Color(red: 0.816, green: 0.953, blue: 0.000).opacity(0.35)

    // MARK: 按钮
    /// 关闭／取消按钮填充
    static let buttonFillClose     = Color(red: 0.953, green: 0.957, blue: 0.965)  // #F3F4F6
    /// 确认按钮填充（次级）
    static let buttonFillConfirm   = Color(red: 0.898, green: 0.906, blue: 0.922)  // #E5E7EB

    // MARK: 日期选择
    /// 未选中日期按钮填充
    static let dateButtonUnselected = Color(red: 0.902, green: 0.902, blue: 0.902) // #E6E6E6
    /// 学期选择 / 学期预览周行默认背景
    static let semesterWeekRow = Color.white
    /// 学期选择 / 学期预览当前周背景
    static let semesterWeekRowHighlight = courseCardFront

    // MARK: 遮罩层
    static let overlayLight = Color.black.opacity(0.20)
    static let overlayMid   = Color.black.opacity(0.30)
    static let overlayStrong = Color.black.opacity(0.76)
    static let overlayGray  = Color(red: 0.561, green: 0.561, blue: 0.561).opacity(0.20)
    static let modalScrim = Color.black.opacity(0.35)

    // MARK: 语义别名（现有组件引用，组件更新后移除）
    /// DateCell 今日高亮背景（与课程卡背面同为设计主蓝）
    static let todayHighlight  = courseCardBack
    /// 格子细描边
    static let borderSubtle    = Color.black.opacity(0.15)
    /// 辅助文字（时间轴标签等）
    static let textSecondary   = Color(red: 0.6, green: 0.6, blue: 0.6)

    // MARK: 杂项
    /// 滚动条把手
    static let scrollHandle      = Color(red: 0.745, green: 0.745, blue: 0.745)  // #BEBEBE
    /// 细分割线
    static let dividerLine       = Color(red: 0.804, green: 0.812, blue: 0.749)  // #CDCFBF
    /// 学期预览课程色点 — 蓝灰
    static let courseIndicatorBlue = Color(red: 0.353, green: 0.482, blue: 0.663) // #5A7BA9
    /// 学期预览课程色点 — 暖棕
    static let courseIndicatorTan  = Color(red: 0.851, green: 0.741, blue: 0.549) // #D9BD8C

    // MARK: TASKS / CourseTaskPopover
    /// 任务浮层外层描边与任务按钮描边
    static let taskBorderPrimary = borderPrimary
    /// 任务浮层外层背景
    static let taskPopoverOuterFill = surfacePrimary
    /// 任务浮层内层背景
    static let taskPopoverInnerFill = surfaceInverse
    /// 任务行与新增空白行背景
    static let taskRowFill = surfacePrimary
    /// 任务浮层遮罩
    static let taskOverlay = overlayGray
    /// 课程卡正面右下角任务存在标记
    static let taskIndicator = courseCardBack
}
