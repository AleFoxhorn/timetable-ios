import Foundation

/// 阶段 1 临时硬编码数据
/// 未来接入数据库后，此文件可能被替换为 Repository 层
enum MockData {

    /// 默认时间表配置（11 节课 + 课间 + 午休/晚休间隔）
    static let defaultTimetableConfig = TimetableConfig(segments: [
        .init(startTime: "08:00", endTime: "08:45", visualHeight: 46, kind: .slot(1)),
        .init(startTime: "08:45", endTime: "08:50", visualHeight:  4, kind: .denseGap),
        .init(startTime: "08:50", endTime: "09:35", visualHeight: 46, kind: .slot(2)),
        .init(startTime: "09:35", endTime: "10:05", visualHeight:  4, kind: .denseGap),
        .init(startTime: "10:05", endTime: "10:50", visualHeight: 46, kind: .slot(3)),
        .init(startTime: "10:50", endTime: "10:55", visualHeight:  4, kind: .denseGap),
        .init(startTime: "10:55", endTime: "11:40", visualHeight: 46, kind: .slot(4)),
        .init(startTime: "11:40", endTime: "13:30", visualHeight: 36, kind: .isolatedGap),
        .init(startTime: "13:30", endTime: "14:15", visualHeight: 46, kind: .slot(5)),
        .init(startTime: "14:15", endTime: "14:20", visualHeight:  4, kind: .denseGap),
        .init(startTime: "14:20", endTime: "15:05", visualHeight: 46, kind: .slot(6)),
        .init(startTime: "15:05", endTime: "15:35", visualHeight:  4, kind: .denseGap),
        .init(startTime: "15:35", endTime: "16:20", visualHeight: 46, kind: .slot(7)),
        .init(startTime: "16:20", endTime: "16:25", visualHeight:  4, kind: .denseGap),
        .init(startTime: "16:25", endTime: "17:10", visualHeight: 46, kind: .slot(8)),
        .init(startTime: "17:10", endTime: "18:00", visualHeight: 36, kind: .isolatedGap),
        .init(startTime: "18:00", endTime: "18:45", visualHeight: 46, kind: .slot(9)),
        .init(startTime: "18:45", endTime: "18:55", visualHeight:  4, kind: .denseGap),
        .init(startTime: "18:55", endTime: "19:40", visualHeight: 46, kind: .slot(10)),
        .init(startTime: "19:40", endTime: "19:50", visualHeight:  4, kind: .denseGap),
        .init(startTime: "19:50", endTime: "20:35", visualHeight: 46, kind: .slot(11)),
    ])

    /// 从 defaultTimetableConfig 提取的 11 个节次开始时间，用于 TimeAxis
    static var times: [String] {
        defaultTimetableConfig.segments.compactMap {
            if case .slot = $0.kind { return $0.startTime }
            return nil
        }
    }

    /// 本周日期数据
    static let currentWeek: [DayInfo] = [
        DayInfo(weekday: "MON", day: 23, isToday: false),
        DayInfo(weekday: "TUE", day: 24, isToday: false),
        DayInfo(weekday: "WED", day: 25, isToday: true),
        DayInfo(weekday: "THU", day: 26, isToday: false),
        DayInfo(weekday: "FRI", day: 27, isToday: false),
        DayInfo(weekday: "SAT", day: 28, isToday: false),
        DayInfo(weekday: "SUN", day: 29, isToday: false)
    ]

    /// 课程数据（6-8 门），配色按 paletteIndex 顺序循环分配
    static let courses: [Course] = [
        Course(id: UUID(), name: "思想政治",
               location: "第二教学楼", classroom: "3-315",
               dayOfWeek: 1, startSlot: 1, endSlot: 2,
               paletteIndex: 0, tasks: []),

        Course(id: UUID(), name: "视觉设计",
               location: "艺术学院", classroom: "A-201",
               dayOfWeek: 2, startSlot: 1, endSlot: 4,
               paletteIndex: 1, tasks: ["看参考资料"]),

        Course(id: UUID(), name: "高等数学",
               location: "理科教学楼", classroom: "B-208",
               dayOfWeek: 3, startSlot: 1, endSlot: 2,
               paletteIndex: 2, tasks: []),

        Course(id: UUID(), name: "工程制图",
               location: "工学院", classroom: "C-301",
               dayOfWeek: 4, startSlot: 3, endSlot: 4,
               paletteIndex: 3, tasks: ["完成作业"]),

        Course(id: UUID(), name: "综合英语",
               location: "外语学院", classroom: "C-204",
               dayOfWeek: 5, startSlot: 1, endSlot: 2,
               paletteIndex: 4, tasks: []),

        Course(id: UUID(), name: "体育理论",
               location: "中心田径场", classroom: "2-253",
               dayOfWeek: 1, startSlot: 5, endSlot: 6,
               paletteIndex: 5, tasks: []),

        Course(id: UUID(), name: "网球专项",
               location: "西区网球场", classroom: "Court2",
               dayOfWeek: 4, startSlot: 7, endSlot: 8,
               paletteIndex: 0, tasks: ["复习规则"]),

        Course(id: UUID(), name: "艺术与审美",
               location: "八角楼", classroom: "A301",
               dayOfWeek: 3, startSlot: 9, endSlot: 10,
               paletteIndex: 1, tasks: [])
    ]

    /// 事项测试数据（4 个，覆盖对齐/跨课间/午休内/跨午休四种情况）
    static let events: [ScheduleEvent] = [
        // 完全对齐节次：周三 节3-4（10:05-11:40）
        ScheduleEvent(id: UUID(), title: "打卡",
                      dayOfWeek: 3,
                      startTime: "10:05", endTime: "11:40"),

        // 跨课间：周二 09:30-10:30（横跨节2内、9:35-10:05课间、节3内）
        ScheduleEvent(id: UUID(), title: "晨会",
                      dayOfWeek: 2,
                      startTime: "09:30", endTime: "10:30"),

        // 落在午休内：周五 12:00-13:00（完全在 11:40-13:30 isolatedGap 内）
        ScheduleEvent(id: UUID(), title: "午餐聚会",
                      dayOfWeek: 5,
                      startTime: "12:00", endTime: "13:00"),

        // 跨午休：周一 11:00-14:00（从节4内开始，跨午休，到节5内结束）
        ScheduleEvent(id: UUID(), title: "长会议",
                      dayOfWeek: 1,
                      startTime: "11:00", endTime: "14:00"),
    ]
}
