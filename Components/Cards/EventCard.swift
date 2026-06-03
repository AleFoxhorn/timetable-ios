import SwiftUI

// EventCard 是双态组件，根据 mode 决定显示实色填充或虚线占位
// mode == .courses 时禁用所有交互
// 长按视觉反馈通过 @GestureState + animation(value:) 实现
// 卡片内边距使用 AppSpacing 令牌，与 CourseCard 共享同一份数据
// startTime / endTime 均为可选：只传入一个则只显示一端时间；均不传则仅显示内容，卡片高度默认 cellHeight
struct EventCard: View {
    /// 开始时间，如 "10:00"；不传则不显示
    let startTime: String?
    /// 结束时间，如 "11:30"；不传则不显示
    let endTime: String?
    /// 事项内容，如 "打卡"
    let content: String
    /// 当前显示模式，决定卡片样式和交互
    let mode: DisplayMode
    /// 长按回调，仅 events 模式下触发
    let onLongPress: () -> Void

    @Environment(\.cardCornerRadius) private var cardCornerRadius
    @GestureState private var isPressed = false

    // 时间不完整时固定为 cellHeight；两端都有时返回 nil，由外层 frame 控制高度
    private var fixedHeight: CGFloat? {
        (startTime == nil || endTime == nil) ? AppSpacing.cellHeight : nil
    }

    @ViewBuilder
    private var cardContent: some View {
        if mode == .events {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(EventCardColors.eventTint)
                .overlay(
                    VStack(spacing: AppSpacing.cardInnerSpacing) {
                        // startTime 与内容文字之间用正常间距；"…" 与内容文字之间用负间距紧凑叠放
                        if let start = startTime {
                            Text(start)
                                .font(AppFonts.caption)
                                .foregroundColor(TextColors.textOnHighlight)
                                .multilineTextAlignment(.center)
                        }

                        let contentResult = content.splitIntoLines(charsPerLine: 2, maxLines: 2)
                        VStack(spacing: AppSpacing.cardTitleLineSpacing) {
                            Text(contentResult.body)
                                .font(AppFonts.captionBold)
                                .foregroundColor(TextColors.textOnHighlight)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            if contentResult.hasEllipsis {
                                Text("…")
                                    .font(AppFonts.captionBold)
                                    .foregroundColor(TextColors.textOnHighlight)
                            }
                        }

                        Spacer(minLength: 0)

                        if let end = endTime {
                            Text(end)
                                .font(AppFonts.caption)
                                .foregroundColor(TextColors.textOnHighlight)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, AppSpacing.cardPaddingVertical)
                    .padding(.horizontal, AppSpacing.cardPaddingHorizontal)
                )
        } else {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: cardCornerRadius)
                        .stroke(
                            EventCardColors.eventTint,
                            style: StrokeStyle(lineWidth: AppSpacing.borderThin, dash: [2, 2])
                        )
                )
        }
    }

    var body: some View {
        if mode == .events {
            cardContent
                .frame(minHeight: AppSpacing.cellHeight, maxHeight: fixedHeight)
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .opacity(isPressed ? 0.85 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: isPressed)
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .updating($isPressed) { _, state, _ in state = true }
                        .onEnded { _ in onLongPress() }
                )
        } else {
            cardContent
                .frame(minHeight: AppSpacing.cellHeight, maxHeight: fixedHeight)
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        Text("完整时间").font(.caption)
        HStack(spacing: 8) {
            EventCard(startTime: "10:00", endTime: "11:30", content: "打卡", mode: .events, onLongPress: {})
                .frame(width: 45, height: 92)
            EventCard(startTime: "10:00", endTime: "11:30", content: "打卡", mode: .courses, onLongPress: {})
                .frame(width: 45, height: 92)
        }

        Text("仅开始时间").font(.caption)
        HStack(spacing: 8) {
            EventCard(startTime: "10:00", endTime: nil, content: "打卡", mode: .events, onLongPress: {})
                .frame(width: 45)
            EventCard(startTime: "10:00", endTime: nil, content: "打卡", mode: .courses, onLongPress: {})
                .frame(width: 45)
        }

        Text("仅结束时间").font(.caption)
        HStack(spacing: 8) {
            EventCard(startTime: nil, endTime: "11:30", content: "打卡", mode: .events, onLongPress: {})
                .frame(width: 45)
            EventCard(startTime: nil, endTime: "11:30", content: "打卡", mode: .courses, onLongPress: {})
                .frame(width: 45)
        }

        Text("无时间（默认 40pt）").font(.caption)
        HStack(spacing: 8) {
            EventCard(startTime: nil, endTime: nil, content: "打卡", mode: .events, onLongPress: {})
                .frame(width: 45)
            EventCard(startTime: nil, endTime: nil, content: "打卡", mode: .courses, onLongPress: {})
                .frame(width: 45)
        }
    }
    .padding(32)
    .background(Color.gray.opacity(0.08))
}
