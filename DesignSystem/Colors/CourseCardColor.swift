import SwiftUI

struct CourseCardColorGroup {
    let backgroundLight: Color
    let backgroundDark: Color
    let text: Color

    var secondaryText: Color {
        text.opacity(0.75)
    }
}

enum CourseCardColors {
    static let lavender = CourseCardColorGroup(
        backgroundLight: Color(red: 0.92, green: 0.88, blue: 0.98),
        backgroundDark: Color(red: 0.82, green: 0.75, blue: 0.93),
        text: Color(red: 0.35, green: 0.27, blue: 0.55)
    )

    static let mint = CourseCardColorGroup(
        backgroundLight: Color(red: 0.85, green: 0.95, blue: 0.92),
        backgroundDark: Color(red: 0.72, green: 0.88, blue: 0.82),
        text: Color(red: 0.20, green: 0.45, blue: 0.40)
    )

    static let pink = CourseCardColorGroup(
        backgroundLight: Color(red: 0.99, green: 0.88, blue: 0.92),
        backgroundDark: Color(red: 0.97, green: 0.78, blue: 0.83),
        text: Color(red: 0.60, green: 0.25, blue: 0.40)
    )

    static let peach = CourseCardColorGroup(
        backgroundLight: Color(red: 1.0, green: 0.92, blue: 0.85),
        backgroundDark: Color(red: 1.0, green: 0.83, blue: 0.72),
        text: Color(red: 0.65, green: 0.40, blue: 0.20)
    )

    static let sky = CourseCardColorGroup(
        backgroundLight: Color(red: 0.88, green: 0.94, blue: 0.98),
        backgroundDark: Color(red: 0.76, green: 0.88, blue: 0.94),
        text: Color(red: 0.20, green: 0.40, blue: 0.60)
    )

    static let lemon = CourseCardColorGroup(
        backgroundLight: Color(red: 1.0, green: 0.97, blue: 0.85),
        backgroundDark: Color(red: 1.0, green: 0.92, blue: 0.72),
        text: Color(red: 0.55, green: 0.45, blue: 0.15)
    )
}

extension CourseColor {
    var colorGroup: CourseCardColorGroup {
        switch self {
        case .lavender: return CourseCardColors.lavender
        case .mint: return CourseCardColors.mint
        case .pink: return CourseCardColors.pink
        case .peach: return CourseCardColors.peach
        case .sky: return CourseCardColors.sky
        case .lemon: return CourseCardColors.lemon
        }
    }
}
