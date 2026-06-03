//
//  AppFonts.swift
//  timetable
//
//  全局字号语义令牌
//  命名规则：按视觉层级命名（caption/body/title 等），不按用途命名
//  添加新字号时，在对应区块下追加，并标注暂定/正式状态
//

import SwiftUI

enum AppFonts {
    
    // MARK: - Caption（小号文字）
    // 用于：时间轴、辅助信息、卡片副文本等
    
    /// 暂定值（来源：TimeAxisCell 时间显示）
    /// 用途：时间轴上方的时间字符串
    static let caption = Font.system(size: 11, weight: .regular)
    
    /// 暂定值（来源：TimeAxisCell 节次数字）
    /// 用途：时间轴中央的节次数字
    static let captionBold = Font.system(size: 16, weight: .semibold)

    /// 暂定值（来源：CourseCard 课程名）
    /// 用途：课程卡片主标题
    static let courseCardTitle = Font.system(size: 14, weight: .bold)
    
    
    // MARK: - Body（正文）

    /// 暂定值（来源：WeekDateBar 月份标签）
    /// 用途：周日期条左侧月份文字
    static let bodyMedium = Font.system(size: 16, weight: .medium)
    
    
    // MARK: - Title（标题）

    /// 暂定值（来源：TopHeader 周数标题）
    /// 用途：界面主标题（如 TopHeader 周数标题）
    static let titleLarge = Font.system(size: 32, weight: .regular)
    
}
