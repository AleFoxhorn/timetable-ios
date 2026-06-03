import Foundation
import CoreGraphics

struct TimetableConfig {

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
