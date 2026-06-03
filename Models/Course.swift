import Foundation

/// 课程数据模型
/// 一门课的完整信息描述
struct Course: Identifiable {
    let id: UUID
    let name: String        // 课程名，如 "思想政治"
    let location: String    // 上课地点，如 "第二教学楼"
    let classroom: String   // 教室号，如 "3-315"
    let dayOfWeek: Int      // 周几（1=周一，7=周日）
    let startSlot: Int      // 开始节次（1-11）
    let endSlot: Int        // 结束节次（1-11）
    let paletteIndex: Int   // 使用第几套配色（0 起算，循环）
    var tasks: [String]     // 课内任务列表
}
