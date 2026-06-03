import SwiftUI

extension String {
    /// 按指定字符数严格分行
    /// - Returns: (主体内容, 是否需要省略号)
    func splitIntoLines(charsPerLine: Int, maxLines: Int) -> (body: String, hasEllipsis: Bool) {
        let chars = Array(self)
        let totalChars = chars.count
        let maxCharsAllowed = charsPerLine * maxLines

        if totalChars <= maxCharsAllowed {
            var result = ""
            for (index, char) in chars.enumerated() {
                result.append(char)
                if (index + 1) % charsPerLine == 0 && index != totalChars - 1 {
                    result.append("\n")
                }
            }
            return (body: result, hasEllipsis: false)
        }

        var result = ""
        let charsForBody = charsPerLine * maxLines
        for index in 0..<charsForBody {
            result.append(chars[index])
            if (index + 1) % charsPerLine == 0 && index != charsForBody - 1 {
                result.append("\n")
            }
        }
        return (body: result, hasEllipsis: true)
    }
}

enum CourseColor: String, CaseIterable {
    case lavender, mint, pink, peach, sky, lemon
}

// Course 数据模型定义在 Models/Course.swift
// 此扩展将 paletteIndex 映射为视图层配色，与设计系统解耦
extension Course {
    var cardColors: CourseCardColorGroup {
        let palette = CourseColor.allCases
        return palette[paletteIndex % palette.count].colorGroup
    }
}

struct CourseCard: View {
    let course: Course
    let tasks: [String]
    let isFlipped: Bool
    let onFlip: () -> Void
    let onViewDetail: () -> Void
    let onAddTask: () -> Void

    @Environment(\.cardCornerRadius) private var cardCornerRadius
    @GestureState private var isLongPressFired = false

    // 高度只由课程节数决定，与任务内容无关
    private var cardHeight: CGFloat {
        let n = CGFloat(course.endSlot - course.startSlot + 1)
        return AppSpacing.cellHeight * n + AppSpacing.columnSpacing * (n - 1)
    }

    // 底部始终为指示点留出空间：点直径 + 点距边缘间距 + 文字与点间距
    private var frontBottomPadding: CGFloat {
        AppSpacing.taskDotSize + 2 * AppSpacing.cardPaddingVertical
    }

    private func chunkText(_ text: String, perLine: Int) -> String {
        let chars = Array(text)
        var result = ""
        for (index, char) in chars.enumerated() {
            result.append(char)
            if (index + 1) % perLine == 0 && index != chars.count - 1 {
                result.append("\n")
            }
        }
        return result
    }

    @ViewBuilder
    private var frontFace: some View {
        let colors = course.cardColors

        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                VStack(spacing: AppSpacing.cardTitleLineSpacing) {
                    let nameResult = course.name.splitIntoLines(charsPerLine: 2, maxLines: 2)

                    Text(nameResult.body)
                        .font(AppFonts.courseCardTitle)
                        .foregroundColor(colors.text)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    if nameResult.hasEllipsis {
                        Text("…")
                            .font(AppFonts.courseCardTitle)
                            .foregroundColor(colors.text)
                    }
                }
                .padding(.top, AppSpacing.cardPaddingVertical)

                Spacer(minLength: AppSpacing.cardPaddingVertical)

                VStack(spacing: AppSpacing.cardInnerSpacing) {
                    if !course.location.isEmpty {
                        VStack(spacing: AppSpacing.cardCaptionLineSpacing) {
                            let locationResult = course.location.splitIntoLines(charsPerLine: 3, maxLines: 2)

                            Text(locationResult.body)
                                .font(AppFonts.caption)
                                .foregroundColor(colors.secondaryText)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            if locationResult.hasEllipsis {
                                Text("…")
                                    .font(AppFonts.caption)
                                    .foregroundColor(colors.secondaryText)
                            }
                        }
                    }

                    if !course.classroom.isEmpty {
                        Text(course.classroom)
                            .font(AppFonts.caption)
                            .foregroundColor(colors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
                .padding(.bottom, frontBottomPadding)
            }
            .padding(.horizontal, AppSpacing.cardPaddingHorizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(
                LinearGradient(
                    colors: [colors.backgroundLight, colors.backgroundDark],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            if !tasks.isEmpty {
                Circle()
                    .stroke(colors.text, lineWidth: AppSpacing.borderThin)
                    .frame(width: AppSpacing.taskDotSize, height: AppSpacing.taskDotSize)
                    .padding(AppSpacing.cardPaddingVertical)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
    }

    // 内容区高度 = 卡片高度 - 上下内边距
    private var backContentHeight: CGFloat {
        cardHeight - 2 * AppSpacing.cardPaddingVertical
    }

    // 将所有任务平铺为逐行数组：同任务内行无额外间距，新任务首行前加 cardInnerSpacing
    // 超量时最后一个可见行替换为"…"（继承原行的间距属性）
    private var linesToDisplay: [(text: String, gap: CGFloat)] {
        var all: [(text: String, gap: CGFloat)] = []
        for (ti, task) in tasks.enumerated() {
            let chunks = chunkText(task, perLine: AppSpacing.taskCharsPerLine)
                .components(separatedBy: "\n")
            for (li, line) in chunks.enumerated() {
                let gap: CGFloat = (li == 0 && ti > 0) ? AppSpacing.cardInnerSpacing : 0
                all.append((text: line, gap: gap))
            }
        }

        let lineH: CGFloat = 13  // 11pt caption ≈ 13pt line height
        var h: CGFloat = 0
        var fit = 0
        for line in all {
            h += line.gap + lineH
            if h <= backContentHeight { fit += 1 } else { break }
        }

        guard fit < all.count else { return all }  // 无超量，全部显示

        // 用"…"替换最后一个可见行，保留该行原有的 gap 属性
        let shown = max(1, fit)
        return Array(all.prefix(shown - 1)) + [(text: "…", gap: all[shown - 1].gap)]
    }

    @ViewBuilder
    private var backFace: some View {
        let colors = course.cardColors

        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(linesToDisplay.enumerated()), id: \.offset) { _, line in
                Text(line.text)
                    .font(AppFonts.caption)
                    .foregroundColor(colors.text)
                    .padding(.top, line.gap)
            }
        }
        .padding(.horizontal, AppSpacing.cardPaddingHorizontal)
        .padding(.vertical, AppSpacing.cardPaddingVertical)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(colors.backgroundLight)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }

    var body: some View {
        ZStack(alignment: .top) {
            backFace
            frontFace
                .opacity(isFlipped ? 0 : 1)
        }
        .frame(height: cardHeight, alignment: .top)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .scaleEffect(isLongPressFired ? 0.95 : 1.0)
        .opacity(isLongPressFired ? 0.85 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isLongPressFired)
        .onTapGesture {
            onFlip()
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($isLongPressFired) { value, state, _ in state = value }
                .onEnded { _ in
                    if isFlipped {
                        onAddTask()
                    } else {
                        onViewDetail()
                    }
                }
        )
    }
}

#Preview {
    let cardWidth = (AppSpacing.courseGridWidth - 6 * AppSpacing.columnSpacing) / 7

    HStack(alignment: .top, spacing: AppSpacing.columnSpacing) {
        // 正面 + 有任务（2节，显示指示点）
        CourseCard(
            course: Course(id: UUID(), name: "思想政治", location: "第二教学楼", classroom: "3-315", dayOfWeek: 1, startSlot: 3, endSlot: 4, paletteIndex: 0, tasks: []),
            tasks: ["复习第三章", "完成作业"],
            isFlipped: false,
            onFlip: {},
            onViewDetail: {},
            onAddTask: {}
        )
        .frame(width: cardWidth)

        // 正面 + 无任务（3节，更高，验证顶端对齐）
        CourseCard(
            course: Course(id: UUID(), name: "视觉设计", location: "艺术楼", classroom: "4-201", dayOfWeek: 2, startSlot: 1, endSlot: 3, paletteIndex: 4, tasks: []),
            tasks: [],
            isFlipped: false,
            onFlip: {},
            onViewDetail: {},
            onAddTask: {}
        )
        .frame(width: cardWidth)

        // 背面 + 正常任务（2节）
        CourseCard(
            course: Course(id: UUID(), name: "高等数学", location: "理科楼", classroom: "A-208", dayOfWeek: 3, startSlot: 5, endSlot: 6, paletteIndex: 1, tasks: []),
            tasks: ["预习第四章", "做题"],
            isFlipped: true,
            onFlip: {},
            onViewDetail: {},
            onAddTask: {}
        )
        .frame(width: cardWidth)

        // 背面 + 任务溢出（2节，内容超出卡片高度，验证裁剪）
        CourseCard(
            course: Course(id: UUID(), name: "体育综合训练", location: "体育馆", classroom: "B1", dayOfWeek: 4, startSlot: 7, endSlot: 8, paletteIndex: 3, tasks: []),
            tasks: ["热身运动准备", "跑步五公里", "力量训练组合", "拉伸放松动作"],
            isFlipped: true,
            onFlip: {},
            onViewDetail: {},
            onAddTask: {}
        )
        .frame(width: cardWidth)
    }
    .padding(24)
    .background(Color.gray.opacity(0.08))
}
