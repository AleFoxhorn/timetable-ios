import SwiftUI

struct TaskButtonReduction: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(AppColors.surfacePrimary)
                Circle()
                    .stroke(AppColors.borderPrimary, lineWidth: 1.5)

                Image(systemName: "minus")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)
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
