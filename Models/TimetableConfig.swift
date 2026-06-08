import Foundation
import CoreGraphics

struct TimetableConfig: Codable, Equatable {
    var id: UUID
    var semesterStartMonday: Date

    init(id: UUID = UUID(), semesterStartMonday: Date) {
        self.id = id
        self.semesterStartMonday = semesterStartMonday
    }
}

struct TimetableLayoutConfig {

    struct Segment {
        let startTime: String
        let endTime: String
        let visualHeight: CGFloat
        let kind: Kind
    }

    enum Kind {
        case slot(Int)
        case denseGap
        case isolatedGap
    }

    let segments: [Segment]
}
