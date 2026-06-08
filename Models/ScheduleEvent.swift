import Foundation

/// 课外事项数据模型
/// 命名为 ScheduleEvent 而非 Event，避免与 Swift 内置类型冲突
struct ScheduleEvent: Identifiable, Codable, Equatable {
    enum RepeatRule: String, Codable, CaseIterable {
        case none
        case weekly

        var displayText: String {
            switch self {
            case .none:
                return "不重复"
            case .weekly:
                return "每周"
            }
        }
    }

    let id: UUID
    var title: String
    var location: String
    var date: Date
    var startTime: String
    var endTime: String
    var repeatRule: RepeatRule
    var weeks: [Int]
    var notes: String

    init(
        id: UUID = UUID(),
        title: String,
        location: String = "",
        date: Date,
        startTime: String,
        endTime: String,
        repeatRule: RepeatRule = .none,
        weeks: [Int],
        notes: String = ""
    ) {
        self.id = id
        self.title = title
        self.location = location
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.repeatRule = repeatRule
        self.weeks = Array(Set(weeks)).sorted()
        self.notes = notes
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case location
        case date
        case startTime
        case endTime
        case repeatRule
        case weeks
        case notes
        case dayOfWeek
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        title = try container.decode(String.self, forKey: .title)
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        startTime = try container.decode(String.self, forKey: .startTime)
        endTime = try container.decode(String.self, forKey: .endTime)
        repeatRule = try container.decodeIfPresent(RepeatRule.self, forKey: .repeatRule) ?? .none
        weeks = (try container.decodeIfPresent([Int].self, forKey: .weeks) ?? [1]).sorted()
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""

        if let decodedDate = try container.decodeIfPresent(Date.self, forKey: .date) {
            date = decodedDate
        } else {
            let legacyWeekday = try container.decodeIfPresent(Int.self, forKey: .dayOfWeek) ?? 1
            date = ScheduleEvent.legacyDate(for: legacyWeekday)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(location, forKey: .location)
        try container.encode(date, forKey: .date)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(repeatRule, forKey: .repeatRule)
        try container.encode(weeks, forKey: .weeks)
        try container.encode(notes, forKey: .notes)
    }

    var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedLocation: String {
        location.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var weekday: Int {
        let systemWeekday = Calendar.current.component(.weekday, from: date)
        return ((systemWeekday + 5) % 7) + 1
    }

    var startMinutes: Int {
        TimeMapper.timeToMinutes(startTime)
    }

    var endMinutes: Int {
        TimeMapper.timeToMinutes(endTime)
    }

    var displayDateText: String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(month)月\(day)日 | 周\(Course.weekdayChinese(weekday))"
    }

    var displayTimeText: String {
        "\(startTime)-\(endTime)"
    }

    static func makeWeeks(
        repeatRule: RepeatRule,
        currentWeek: Int,
        totalWeeks: Int
    ) -> [Int] {
        guard repeatRule == .weekly else { return [currentWeek] }
        return Array(currentWeek...max(currentWeek, totalWeeks))
    }

    static func overlaps(
        startMinutes lhsStart: Int,
        endMinutes lhsEnd: Int,
        otherStartMinutes rhsStart: Int,
        otherEndMinutes rhsEnd: Int
    ) -> Bool {
        max(lhsStart, rhsStart) < min(lhsEnd, rhsEnd)
    }

    private static func legacyDate(for weekday: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let weekdayIndex = calendar.component(.weekday, from: today)
        let mondayOffset = (weekdayIndex + 5) % 7
        let weekStart = calendar.date(byAdding: .day, value: -mondayOffset, to: calendar.startOfDay(for: today)) ?? today
        let mondayBasedOffset = max(0, min(6, weekday - 1))
        return calendar.date(byAdding: .day, value: mondayBasedOffset, to: weekStart) ?? today
    }
}
