import SwiftUI

struct EventCard: View {
    let startTime: String
    let endTime: String
    let content: String
    /// .events = 正面亮起（黄底显内容），.courses = 背面暗置（半透明描边占位）
    let mode: DisplayMode
    let onLongPress: () -> Void

    @GestureState private var isPressed = false

    private var isActive: Bool { mode == .events }

    // 背面：半透明黄底 + 2px 黄色实线描边，无内容
    @ViewBuilder
    private var backFace: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(AppColors.eventCardBackFill)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppColors.eventAccent, lineWidth: 2)
            )
    }

    // 正面：亮黄底，开始时间（上）+ 内容（居中填满）+ 结束时间（下）
    @ViewBuilder
    private var frontFace: some View {
        VStack(spacing: 0) {
            Text(startTime)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(content)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            Text(endTime)
                .font(.system(size: 10))
                .foregroundColor(AppColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .background(AppColors.eventAccent)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    var body: some View {
        ZStack {
            backFace
                .opacity(isActive ? 0 : 1)

            frontFace
                .opacity(isActive ? 1 : 0)
                .scaleEffect(isActive ? 1.0 : 0.9)
        }
        // 点亮/熄灭动画：弹簧感出现，easeIn 消失
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isActive)
        // 长按视觉反馈（仅 events 模式）
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .opacity(isPressed ? 0.85 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($isPressed) { _, state, _ in
                    if isActive { state = true }
                }
                .onEnded { _ in
                    if isActive { onLongPress() }
                }
        )
    }
}

#Preview {
    struct Wrapper: View {
        @State private var mode: DisplayMode = .courses

        var body: some View {
            VStack(spacing: 32) {
                Button(mode == .courses ? "→ 切换到事项模式" : "→ 切换到课程模式") {
                    mode = mode == .courses ? .events : .courses
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)

                HStack(alignment: .top, spacing: 8) {
                    // Figma 参考尺寸 45×86
                    EventCard(startTime: "11:15", endTime: "14:00", content: "开会",
                              mode: mode, onLongPress: {})
                        .frame(width: 45, height: 86)

                    // 较高的卡片（跨多节）
                    EventCard(startTime: "10:05", endTime: "11:40", content: "打卡",
                              mode: mode, onLongPress: {})
                        .frame(width: 45, height: 96)

                    // 长内容
                    EventCard(startTime: "13:30", endTime: "15:05", content: "午餐聚会",
                              mode: mode, onLongPress: {})
                        .frame(width: 45, height: 96)
                }
            }
            .padding(32)
            .background(Color.black)
        }
    }
    return Wrapper()
}
