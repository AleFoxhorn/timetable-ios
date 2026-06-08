import Foundation

struct Course: Identifiable, Codable {
    enum WeekPattern: String, Codable, CaseIterable {
        case every
        case odd
        case even

        var displayText: String {
            switch self {
            case .every: return ""
            case .odd: return "单周"
            case .even: return "双周"
            }
        }
    }

    enum Status: String, Codable {
        case complete
        case incomplete
    }

    var id: UUID = UUID()
    var name: String
    var locationRaw: String
    var location: String
    var classroom: String
    var teacher: String
    var weekday: Int
    var startSlot: Int
    var endSlot: Int
    var weeks: [Int]
    var weekPattern: WeekPattern
    var status: Status

    init(
        id: UUID = UUID(),
        name: String,
        classroom: String = "",
        locationRaw: String? = nil,
        location: String? = nil,
        teacher: String = "",
        weekday: Int,
        startSlot: Int,
        endSlot: Int,
        weeks: [Int] = [],
        weekPattern: WeekPattern = .every,
        status: Status? = nil
    ) {
        let resolvedLocationRaw = locationRaw ?? classroom
        let parsed = Course.splitLocation(resolvedLocationRaw)
        let resolvedLocation = location ?? parsed.location
        let resolvedClassroom = classroom.isEmpty ? parsed.classroom : classroom

        self.id = id
        self.name = name
        self.locationRaw = resolvedLocationRaw
        self.location = resolvedLocation
        self.classroom = resolvedClassroom
        self.teacher = teacher
        self.weekday = weekday
        self.startSlot = startSlot
        self.endSlot = endSlot
        self.weeks = weeks.sorted()
        self.weekPattern = weekPattern
        self.status = status ?? Course.deriveStatus(
            name: name,
            locationRaw: resolvedLocationRaw,
            teacher: teacher
        )
    }

    static func deriveStatus(name: String, locationRaw: String, teacher: String) -> Status {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedLocation = locationRaw.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedTeacher = teacher.trimmingCharacters(in: .whitespacesAndNewlines)
        return normalizedName.isEmpty || normalizedLocation.isEmpty || normalizedTeacher.isEmpty
            ? .incomplete
            : .complete
    }

    static func splitLocation(_ raw: String) -> (location: String, classroom: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return ("", "") }

        let parts = trimmed.split(separator: " ").map(String.init)
        guard parts.count >= 2 else { return ("", trimmed) }

        let classroom = parts.last ?? ""
        let location = parts.dropLast().joined(separator: " ")
        return (location, classroom)
    }

    var displayTimeText: String {
        "周\(Course.weekdayChinese(weekday)) | \(startSlot)-\(endSlot)节"
    }

    var displayWeekText: String {
        let merged = Course.mergeWeeks(weeks)
        guard weekPattern != .every else { return merged }
        return merged.isEmpty ? weekPattern.displayText : "\(merged) | \(weekPattern.displayText)"
    }

    static func weekdayChinese(_ weekday: Int) -> String {
        switch weekday {
        case 1: return "一"
        case 2: return "二"
        case 3: return "三"
        case 4: return "四"
        case 5: return "五"
        case 6: return "六"
        case 7: return "日"
        default: return "?"
        }
    }

    static func mergeWeeks(_ weeks: [Int]) -> String {
        let sorted = Array(Set(weeks)).sorted()
        guard !sorted.isEmpty else { return "" }

        var ranges: [(Int, Int)] = []
        var start = sorted[0]
        var end = sorted[0]

        for week in sorted.dropFirst() {
            if week == end + 1 {
                end = week
            } else {
                ranges.append((start, end))
                start = week
                end = week
            }
        }
        ranges.append((start, end))

        return ranges.map { start, end in
            start == end ? "\(start)周" : "\(start)-\(end)周"
        }
        .joined(separator: "，")
    }
}
