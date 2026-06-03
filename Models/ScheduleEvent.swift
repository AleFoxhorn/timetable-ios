import Foundation

/// 课外事项数据模型
/// 命名为 ScheduleEvent 而非 Event，避免与 Swift 内置类型冲突
struct ScheduleEvent: Identifiable {
    let id: UUID
    let title: String
    let dayOfWeek: Int
    let startTime: String
    let endTime: String
}
