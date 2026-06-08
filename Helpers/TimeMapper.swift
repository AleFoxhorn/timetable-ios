import Foundation
import CoreGraphics

/// 时间字符串到屏幕 y 坐标的映射工具
/// 设计为命名空间枚举，不需要实例化
enum TimeMapper {

    // MARK: - 基础工具

    /// 将 "HH:mm" 格式的时间字符串转换为从凌晨 0 点起的总分钟数
    /// 例：timeToMinutes("10:00") = 600
    /// 格式错误（非 "HH:mm"、非数字）时返回 0，不崩溃
    static func timeToMinutes(_ time: String) -> Int {
        let parts = time.split(separator: ":")
        guard parts.count == 2,
              let h = Int(parts[0]),
              let m = Int(parts[1]) else { return 0 }
        return h * 60 + m
    }

    /// 计算时间表的总视觉高度（所有 segment.visualHeight 之和）
    static func totalHeight(config: TimetableLayoutConfig) -> CGFloat {
        config.segments.reduce(0) { $0 + $1.visualHeight }
    }

    // MARK: - 核心映射

    /// 将 "HH:mm" 时间映射到时间表中的 y 坐标（相对于时间表顶部，单位 pt）
    ///
    /// 算法：
    ///   1. 遍历 segments，将已完整经过的 segment 的 visualHeight 累加为基准 y
    ///   2. 当 time 落在某个 segment 的 [startTime, endTime) 区间内时，
    ///      按线性比例插值：ratio = (time - segStart) / (segEnd - segStart)
    ///      返回 y + ratio × segment.visualHeight
    ///   3. time 恰好等于 segment.endTime 时，不满足"< segEnd"条件，
    ///      自然归入下一个 segment 的起点（y 坐标），实现"边界归后"语义
    ///
    /// 越界处理：
    ///   - 早于第一个 segment：返回 0
    ///   - 晚于最后一个 segment：返回 totalHeight
    static func timeToY(_ time: String, config: TimetableLayoutConfig) -> CGFloat {
        let timeMin = timeToMinutes(time)
        var y: CGFloat = 0

        for segment in config.segments {
            let segStart = timeToMinutes(segment.startTime)
            let segEnd   = timeToMinutes(segment.endTime)

            // time 早于本 segment 起点（两段之间存在真实时间缝隙时）：返回当前累计 y
            if timeMin < segStart { return y }

            // time 落在本 segment 内（含起点，严格不含终点）
            if timeMin < segEnd {
                let ratio = CGFloat(timeMin - segStart) / CGFloat(segEnd - segStart)
                return y + ratio * segment.visualHeight
            }

            // time 等于或晚于本 segment 终点：累加高度，继续向后
            y += segment.visualHeight
        }

        // time 晚于所有 segment：返回总高度
        return y
    }

    /// 将节次范围映射到时间表中的 y 坐标和视觉高度
    ///
    /// 用于课程卡片定位。课程严格对齐节次，不需要时间字符串插值。
    ///
    /// 算法：
    ///   - y：startSlot 对应 segment 之前所有 segment 的 visualHeight 之和
    ///   - height：从 startSlot 对应 segment 到 endSlot 对应 segment（含两端及其间全部课间段）
    ///     的所有 segment.visualHeight 之和
    ///
    /// 若 startSlot 或 endSlot 在 config 中找不到对应 .slot(n)，返回 (0, 0)
    static func slotToYAndHeight(
        startSlot: Int,
        endSlot: Int,
        config: TimetableLayoutConfig
    ) -> (y: CGFloat, height: CGFloat) {
        var y: CGFloat = 0
        var height: CGFloat = 0
        var capturing = false

        for segment in config.segments {
            // 遇到 startSlot 对应节次，开始捕获
            if case .slot(let n) = segment.kind, n == startSlot {
                capturing = true
            }

            if capturing {
                height += segment.visualHeight
            } else {
                y += segment.visualHeight
            }

            // 遇到 endSlot 对应节次，捕获完成
            if capturing, case .slot(let n) = segment.kind, n == endSlot {
                break
            }
        }

        return (y: y, height: height)
    }
}
