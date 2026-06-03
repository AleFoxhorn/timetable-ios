import SwiftUI

struct ScheduleScreen: View {

    @State private var mode: DisplayMode = .courses
    @State private var flippedCardId: UUID? = nil

    // 7 列等分：总网格宽度减去 6 个列间距后平均分
    private var columnWidth: CGFloat {
        (AppSpacing.courseGridWidth - 6 * AppSpacing.columnSpacing) / 7
    }

    // 在事项模式下与课程卡片交互时，自动切回课程模式
    private func returnToCoursesIfNeeded() {
        guard mode == .events else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            mode = .courses
        }
    }

    var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()

            VStack(spacing: 12) {
                TopHeader(
                    weekTitle: "第十周",
                    onNewSchedule: { print("new schedule") },
                    onAddItem: { print("add item") }
                )

                WeekDateBar(
                    month: "May",
                    days: MockData.currentWeek
                )

                // 网格区域：可垂直滚动，内部结构为时间轴 + 绝对定位双层网格
                ScrollView(.vertical, showsIndicators: false) {
                    // TimeAxis 和网格的视觉对齐依赖两者高度规则一致：
                    // 46pt 节次 + 4pt denseGap + 36pt isolatedGap，与 TimetableConfig 完全对应
                    HStack(alignment: .top, spacing: 0) {

                        // 左侧时间轴容器：65pt 宽，TimeAxis 水平居中
                        HStack {
                            Spacer()
                            TimeAxis(times: MockData.times)
                            Spacer()
                        }
                        .frame(width: 65)

                        // 右侧网格：ZStack + offset 绝对定位
                        // 课程层在底（先写），事项层在顶（后写），自动实现层叠语义
                        ZStack(alignment: .topLeading) {

                            // ── 课程层（底层）──
                            // 使用 TimeMapper.slotToYAndHeight 按节次序号精确定位
                            ForEach(MockData.courses) { course in
                                let pos = TimeMapper.slotToYAndHeight(
                                    startSlot: course.startSlot,
                                    endSlot: course.endSlot,
                                    config: MockData.defaultTimetableConfig
                                )
                                let xOffset = CGFloat(course.dayOfWeek - 1)
                                    * (columnWidth + AppSpacing.columnSpacing)

                                CourseCard(
                                    course: course,
                                    tasks: course.tasks,
                                    isFlipped: flippedCardId == course.id,
                                    onFlip: {
                                        withAnimation(.easeInOut(duration: 0.4)) {
                                            flippedCardId = (flippedCardId == course.id)
                                                ? nil : course.id
                                            if mode == .events { mode = .courses }
                                        }
                                    },
                                    onViewDetail: {
                                        print("view detail: \(course.name)")
                                        returnToCoursesIfNeeded()
                                    },
                                    onAddTask: {
                                        print("add task to: \(course.name)")
                                        returnToCoursesIfNeeded()
                                    }
                                )
                                .frame(width: columnWidth, height: pos.height)
                                .offset(x: xOffset, y: pos.y)
                            }

                            // ── 事项层（顶层）──
                            // 使用 TimeMapper.timeToY 按时间字符串精确插值定位
                            // max(..., 0) 防止数据错误导致负高度崩溃
                            ForEach(MockData.events) { event in
                                let startY = TimeMapper.timeToY(
                                    event.startTime,
                                    config: MockData.defaultTimetableConfig
                                )
                                let endY = TimeMapper.timeToY(
                                    event.endTime,
                                    config: MockData.defaultTimetableConfig
                                )
                                let height = max(endY - startY, 0)
                                let xOffset = CGFloat(event.dayOfWeek - 1)
                                    * (columnWidth + AppSpacing.columnSpacing)

                                EventCard(
                                    startTime: event.startTime,
                                    endTime: event.endTime,
                                    content: event.title,
                                    mode: mode,
                                    onLongPress: { print("long press event: \(event.title)") }
                                )
                                .frame(width: columnWidth, height: height)
                                .offset(x: xOffset, y: startY)
                            }
                        }
                        .frame(
                            width: AppSpacing.courseGridWidth,
                            height: TimeMapper.totalHeight(config: MockData.defaultTimetableConfig),
                            alignment: .topLeading
                        )
                    }
                }

                Spacer()

                // onToggle 不在此处包装 withAnimation，BottomToggleBar 内部已包装
                BottomToggleBar(
                    mode: mode,
                    onToggle: {
                        flippedCardId = nil
                        mode = (mode == .courses) ? .events : .courses
                    },
                    onAdd: { print("add new event") }
                )
            }
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    ScheduleScreen()
}
