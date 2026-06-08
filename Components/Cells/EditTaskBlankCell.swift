import SwiftUI

struct EditTaskBlankCell: View {
    let isAddEnabled: Bool
    let onTapAdd: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: CardCornerRadius.taskRowPill)
                .fill(AppColors.taskRowFill)
                .overlay(
                    RoundedRectangle(cornerRadius: CardCornerRadius.taskRowPill)
                        .stroke(AppColors.taskBorderPrimary, lineWidth: 1)
                )
                .frame(width: AppSpacing.taskAddRowWidth, height: AppSpacing.taskAddRowHeight)

            TaskButtonPlus(onTap: onTapAdd)
                .disabled(!isAddEnabled)
                .offset(x: AppSpacing.taskAddButtonLeading, y: 10)
        }
        .frame(width: AppSpacing.taskPopoverInnerWidth, height: AppSpacing.taskAddRowHeight, alignment: .leading)
    }
}

#Preview {
    EditTaskBlankCell(isAddEnabled: true, onTapAdd: {})
        .padding()
        .background(Color.black)
}
