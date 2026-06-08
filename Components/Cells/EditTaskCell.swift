import SwiftUI

struct EditTaskCell: View {
    let text: String
    let isNewTask: Bool
    let isFirstRow: Bool
    let onTextChange: (String) -> Void
    let onDelete: (() -> Void)?
    let focusedField: FocusState<CourseTaskPopover.TaskFieldFocus?>.Binding
    let focusTarget: CourseTaskPopover.TaskFieldFocus?

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextField("", text: Binding(
                get: { text },
                set: onTextChange
            ), axis: .vertical)
            .font(AppFonts.taskBody)
            .foregroundColor(AppColors.textPrimary)
            .lineLimit(1...)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused(focusedField, equals: focusTarget)
            .frame(width: AppSpacing.taskTextWidth, height: AppSpacing.taskRowHeight, alignment: .leading)
            .offset(x: AppSpacing.taskTextLeading, y: 0)

            if let onDelete, !isNewTask {
                TaskButtonReduction(onTap: onDelete)
                    .offset(x: AppSpacing.taskDeleteButtonLeading, y: 10)
            }
        }
        .frame(
            minWidth: AppSpacing.taskPopoverInnerWidth,
            idealWidth: AppSpacing.taskPopoverInnerWidth,
            maxWidth: AppSpacing.taskPopoverInnerWidth,
            minHeight: AppSpacing.taskRowHeight,
            maxHeight: AppSpacing.taskRowHeight,
            alignment: .leading
        )
        .background(AppColors.taskRowFill)
        .clipShape(rowShape)
        .overlay(rowShape.stroke(AppColors.taskBorderPrimary, lineWidth: 1))
    }

    private var rowShape: some Shape {
        UnevenRoundedRectangle(
            topLeadingRadius: CardCornerRadius.taskRowPill,
            bottomLeadingRadius: CardCornerRadius.taskRowPill,
            bottomTrailingRadius: CardCornerRadius.taskRowPill,
            topTrailingRadius: CardCornerRadius.taskRowPill
        )
    }
}
