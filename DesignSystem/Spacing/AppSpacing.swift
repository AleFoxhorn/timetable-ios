import SwiftUI

enum AppSpacing {

    // MARK: - TIMETABLE / Semester Flow

    /// `selectweekrowsection` 行间距
    static let semesterWeekRowGap: CGFloat = 2

    /// `weekrow1` 星期标题列间距
    static let semesterWeekHeaderGap: CGFloat = 5

    /// `selectweektitle` 水平内边距
    static let semesterWeekTitleHorizontalPadding: CGFloat = 4

    /// `selectweektitle` 顶部内边距
    static let semesterWeekTitleTopPadding: CGFloat = 7

    /// `selectweektitle` 底部内边距
    static let semesterWeekTitleBottomPadding: CGFloat = 6

    /// `selectweekrow` 水平内边距
    static let semesterWeekRowHorizontalPadding: CGFloat = 15

    /// `Selectatimeperiod` / `SemesterPreview` 顶部主内容起始间距
    static let semesterScreenTopPadding: CGFloat = 21

    /// `TopHeader` 标题区通用水平内边距
    static let topHeaderHorizontalPadding: CGFloat = 15

    // MARK: - TASKS / CourseTaskPopover

    /// `CourseTaskPopover` 外层宽度
    static let taskPopoverOuterWidth: CGFloat = 238

    /// `CourseTaskPopover` 内层宽度
    static let taskPopoverInnerWidth: CGFloat = 222

    /// `tasklistcell` 常规任务行高度
    static let taskRowHeight: CGFloat = 46

    /// `tasklistcell` 文本宽度
    static let taskTextWidth: CGFloat = 192

    /// `edittaskblank` 新增入口行高度
    static let taskAddRowHeight: CGFloat = 46

    /// `edittaskblank` 空白行宽度
    static let taskAddRowWidth: CGFloat = 220

    /// 任务文本左内边距
    static let taskTextLeading: CGFloat = 17

    /// 新增按钮左侧偏移
    static let taskAddButtonLeading: CGFloat = 10

    /// 删除按钮左侧偏移
    static let taskDeleteButtonLeading: CGFloat = 187

    /// 任务增减按钮尺寸
    static let taskActionButtonSize: CGFloat = 27

    /// 任务浮层内层顶部偏移
    static let taskPopoverInnerTop: CGFloat = 10

    /// 任务浮层内层左侧偏移
    static let taskPopoverInnerLeading: CGFloat = 8

    /// 任务行之间的描边重叠量
    static let taskRowOverlap: CGFloat = -1
}
