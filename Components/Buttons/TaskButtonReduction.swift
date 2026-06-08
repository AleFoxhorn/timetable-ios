import SwiftUI

struct TaskButtonReduction: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(AppColors.surfaceInverse)

                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.surfacePrimary)
            }
            .frame(width: AppSpacing.taskActionButtonSize, height: AppSpacing.taskActionButtonSize)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TaskButtonReduction(onTap: {})
        .padding()
        .background(Color.white)
}
