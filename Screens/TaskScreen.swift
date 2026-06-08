import SwiftUI

struct TaskScreen: View {
    var body: some View {
        ZStack {
            AppColors.screenBackground
                .ignoresSafeArea()
            Text("TaskScreen")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
        }
    }
}

#Preview {
    TaskScreen()
}
