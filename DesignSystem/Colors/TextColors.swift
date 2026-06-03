//
//  AppColors.swift
//  timetable
//
//  全局颜色语义令牌
//  命名规则：按语义命名（textPrimary/background 等），不按视觉描述命名
//  添加新颜色时，在对应区块下追加，并标注暂定/正式状态
//

import SwiftUI

enum TextColors {
    
    // MARK: - 文字颜色
    
    /// 暂定值
    /// 用途：主要文字内容（节次数字等强调信息）
    static let textPrimary = Color.black
    
    /// 暂定值
    /// 用途：次要文字内容（时间标签等辅助信息）
    static let textSecondary = Color.gray
    /// 暂定值
    /// 用途：在高亮背景上的文字颜色（如今天日期格、紫色事项卡片等）
    static let textOnHighlight = Color.white
    
    
}
