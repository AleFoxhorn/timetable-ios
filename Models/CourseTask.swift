import Foundation

struct CourseTask: Identifiable, Codable, Hashable {
    var id: UUID
    var courseCardInstanceId: UUID
    var text: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        courseCardInstanceId: UUID,
        text: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.courseCardInstanceId = courseCardInstanceId
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
