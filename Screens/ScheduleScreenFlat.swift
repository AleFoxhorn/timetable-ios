import SwiftUI

// 圆角禁用测试版，用于对比不同视觉风格
// 通过 .environment(\.cardCornerRadius, 0) 将圆角覆盖为 0
// 所有交互逻辑、数据、布局与 ScheduleScreen 完全一致
struct ScheduleScreenFlat: View {
    var body: some View {
        ScheduleScreen()
            .environment(\.cardCornerRadius, 0)
    }
}

#Preview {
    ScheduleScreenFlat()
}
