import SwiftUI

enum AppSpacing {

    // MARK: - 边框粗细

    /// 暂定值
    /// 用途：卡片细描边粗细
    static let borderThin: CGFloat = 1

    /// 暂定值
    /// 用途：格子淡描边（TimeAxisCell、EmptySlotCard）
    static let borderUltraThin: CGFloat = 0.5

    // MARK: - 纵向排列间距

    /// 密集间距，用于同组卡片紧密堆叠
    static let rowSpacingDense: CGFloat = 4

    /// 隔离间距，用于不同区块之间的视觉分隔
    static let rowSpacingIsolated: CGFloat = 36

    // MARK: - 卡片圆角

    /// 所有卡片和格子的统一圆角半径
    static let cardCornerRadius: CGFloat = 10

    // MARK: - 时间轴宽度

    /// 时间轴列（TimeAxisCell / TimeAxis）的固定宽度
    static let timeAxisWidth: CGFloat = 34

    // MARK: - 屏幕水平边距

    /// 界面内容距屏幕左右边缘的间距（如 TopHeader 按钮边距）
    static let screenPaddingHorizontal: CGFloat = 20

    // MARK: - 单元高度

    /// 单节课程格的标准高度，CourseCard / EmptySlotCard / TimeAxisCell / EventCard 共用
    static let cellHeight: CGFloat = 46

    // MARK: - 卡片内部元素间距

    /// 卡片内相邻文字元素之间的正常间距（如时间标签与内容文字之间）
    static let cardInnerSpacing: CGFloat = 2

    // MARK: - 卡片文字行距

    /// 课程名 / 事项内容文字（14–16pt）与省略号之间的行间距（负值使文字紧凑叠放）
    static let cardTitleLineSpacing: CGFloat = -8

    /// 卡片副文字（caption 11pt）与省略号之间的行间距
    static let cardCaptionLineSpacing: CGFloat = -3

    // MARK: - 卡片内边距

    /// 暂定值（来源：CourseCard 原始数值）
    /// 用途：卡片上下边缘内边距
    static let cardPaddingVertical: CGFloat = 4

    /// 暂定值（来源：CourseCard 原始数值）
    /// 用途：卡片左右边缘内边距
    static let cardPaddingHorizontal: CGFloat = 4

    // MARK: - 横向卡片网格

    /// 课程区域总宽度，7 列等分
    static let courseGridWidth: CGFloat = 318

    /// 7 列网格中所有横向元素（DateCell、CourseCard 等）之间的列间距
    static let columnSpacing: CGFloat = 4

    // MARK: - 卡片装饰元素

    /// 任务指示点直径
    static let taskDotSize: CGFloat = 8

    // MARK: - 文字布局

    /// 暂定值
    /// 用途：卡片内任务文字每行最多字符数
    static let taskCharsPerLine: Int = 3

}
