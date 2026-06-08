import Foundation

struct CourseCardInstance: Identifiable, Codable, Hashable {
    struct StableKey: Hashable {
        let courseId: UUID
        let week: Int
        let weekday: Int
        let startSlot: Int
        let endSlot: Int
    }

    var id: UUID
    var courseId: UUID
    var week: Int
    var weekday: Int
    var startSlot: Int
    var endSlot: Int

    init(
        id: UUID = UUID(),
        courseId: UUID,
        week: Int,
        weekday: Int,
        startSlot: Int,
        endSlot: Int
    ) {
        self.id = id
        self.courseId = courseId
        self.week = week
        self.weekday = weekday
        self.startSlot = startSlot
        self.endSlot = endSlot
    }

    var stableKey: StableKey {
        StableKey(
            courseId: courseId,
            week: week,
            weekday: weekday,
            startSlot: startSlot,
            endSlot: endSlot
        )
    }
}
