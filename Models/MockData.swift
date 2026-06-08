import Foundation

enum MockData {

    static let defaultTimetableConfig = TimetableLayoutConfig(segments: [
        .init(startTime: "08:00", endTime: "08:45", visualHeight: 47, kind: .slot(1)),
        .init(startTime: "08:45", endTime: "08:50", visualHeight:  1, kind: .denseGap),
        .init(startTime: "08:50", endTime: "09:35", visualHeight: 47, kind: .slot(2)),
        .init(startTime: "09:35", endTime: "10:05", visualHeight:  1, kind: .denseGap),
        .init(startTime: "10:05", endTime: "10:50", visualHeight: 47, kind: .slot(3)),
        .init(startTime: "10:50", endTime: "10:55", visualHeight:  1, kind: .denseGap),
        .init(startTime: "10:55", endTime: "11:40", visualHeight: 47, kind: .slot(4)),
        .init(startTime: "11:40", endTime: "13:30", visualHeight: 15, kind: .isolatedGap),
        .init(startTime: "13:30", endTime: "14:15", visualHeight: 47, kind: .slot(5)),
        .init(startTime: "14:15", endTime: "14:20", visualHeight:  1, kind: .denseGap),
        .init(startTime: "14:20", endTime: "15:05", visualHeight: 47, kind: .slot(6)),
        .init(startTime: "15:05", endTime: "15:35", visualHeight:  1, kind: .denseGap),
        .init(startTime: "15:35", endTime: "16:20", visualHeight: 47, kind: .slot(7)),
        .init(startTime: "16:20", endTime: "16:25", visualHeight:  1, kind: .denseGap),
        .init(startTime: "16:25", endTime: "17:10", visualHeight: 47, kind: .slot(8)),
        .init(startTime: "17:10", endTime: "18:00", visualHeight: 15, kind: .isolatedGap),
        .init(startTime: "18:00", endTime: "18:45", visualHeight: 47, kind: .slot(9)),
        .init(startTime: "18:45", endTime: "18:55", visualHeight:  1, kind: .denseGap),
        .init(startTime: "18:55", endTime: "19:40", visualHeight: 47, kind: .slot(10)),
        .init(startTime: "19:40", endTime: "19:50", visualHeight:  1, kind: .denseGap),
        .init(startTime: "19:50", endTime: "20:35", visualHeight: 47, kind: .slot(11)),
        .init(startTime: "20:35", endTime: "20:45", visualHeight:  1, kind: .denseGap),
        .init(startTime: "20:45", endTime: "21:30", visualHeight: 47, kind: .slot(12)),
    ])

    static var times: [String] {
        defaultTimetableConfig.segments.compactMap {
            if case .slot = $0.kind { return $0.startTime }
            return nil
        }
    }

    static let currentWeek: [DayInfo] = [
        DayInfo(weekday: "MON", day: 23, isToday: false),
        DayInfo(weekday: "TUE", day: 24, isToday: false),
        DayInfo(weekday: "WED", day: 25, isToday: true),
        DayInfo(weekday: "THU", day: 26, isToday: false),
        DayInfo(weekday: "FRI", day: 27, isToday: false),
        DayInfo(weekday: "SAT", day: 28, isToday: false),
        DayInfo(weekday: "SUN", day: 29, isToday: false)
    ]

    static let courses: [Course] = [
        Course(name: "思想政治", classroom: "第二教学楼 3-315", teacher: "陈老师", weekday: 1, startSlot: 1,  endSlot: 2, weeks: Array(1...16)),
        Course(name: "视觉设计", classroom: "艺术楼 A-201",    teacher: "李老师", weekday: 2, startSlot: 1,  endSlot: 4, weeks: Array(1...16)),
        Course(name: "高等数学", classroom: "B-208",           teacher: "王老师", weekday: 3, startSlot: 1,  endSlot: 2, weeks: Array(1...16)),
        Course(name: "工程制图", classroom: "C-301",           teacher: "刘老师", weekday: 4, startSlot: 3,  endSlot: 4, weeks: [1, 2, 3, 5, 7, 8]),
        Course(name: "综合英语", classroom: "C-204",           teacher: "张老师", weekday: 5, startSlot: 1,  endSlot: 2, weeks: Array(1...16), weekPattern: .odd),
        Course(name: "体育理论", classroom: "2-253",           teacher: "赵老师", weekday: 1, startSlot: 5,  endSlot: 6, weeks: Array(1...16)),
        Course(name: "网球专项", classroom: "体育馆 Court2",   teacher: "孙老师", weekday: 4, startSlot: 7,  endSlot: 8, weeks: Array(1...16)),
        Course(name: "艺术与审美", classroom: "A-301",         teacher: "周老师", weekday: 3, startSlot: 9,  endSlot: 10, weeks: Array(1...16), weekPattern: .even),
    ]

    static let events: [ScheduleEvent] = {
        func currentAcademicWeek() -> Int {
            let calendar = Calendar.current
            var comps = DateComponents()
            comps.year = 2025
            comps.month = 2
            comps.day = 24
            let semesterStart = calendar.date(from: comps) ?? Date()
            let days = calendar.dateComponents([.day], from: semesterStart, to: Date()).day ?? 0
            return min(20, max(1, days / 7 + 1))
        }

        func dateForCurrentWeek(dayOffset: Int) -> Date {
            let calendar = Calendar.current
            let today = Date()
            let weekday = calendar.component(.weekday, from: today)
            let mondayOffset = (weekday + 5) % 7
            let reference = calendar.date(
                byAdding: .day,
                value: -mondayOffset,
                to: calendar.startOfDay(for: today)
            ) ?? today
            return calendar.date(byAdding: .day, value: dayOffset, to: reference) ?? Date()
        }

        let week = currentAcademicWeek()

        return [
            ScheduleEvent(title: "打卡", location: "", date: dateForCurrentWeek(dayOffset: 2), startTime: "10:05", endTime: "11:40", repeatRule: .none, weeks: [week]),
            ScheduleEvent(title: "晨会", location: "第二教学馆305", date: dateForCurrentWeek(dayOffset: 1), startTime: "09:30", endTime: "10:30", repeatRule: .weekly, weeks: Array(week...20)),
            ScheduleEvent(title: "午餐聚会", location: "", date: dateForCurrentWeek(dayOffset: 4), startTime: "12:00", endTime: "13:00", repeatRule: .none, weeks: [week], notes: "记得提前到场"),
            ScheduleEvent(title: "长会议", location: "会议室A", date: dateForCurrentWeek(dayOffset: 0), startTime: "11:00", endTime: "14:00", repeatRule: .none, weeks: [week]),
        ]
    }()
}
