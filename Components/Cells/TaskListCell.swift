import SwiftUI

enum TaskListCellVariant {
    case display
    case edit
    case add
}

struct TaskListCell: View {
    let taskId: UUID?
    let text: String
    let variant: TaskListCellVariant
    let isFirstRow: Bool
    let isAddEnabled: Bool
    let focusedField: FocusState<CourseTaskPopover.TaskFieldFocus?>.Binding
    let focusTarget: CourseTaskPopover.TaskFieldFocus?
    let onTapTask: (() -> Void)?
    let onTapAdd: (() -> Void)?
    let onTextChange: ((String) -> Void)?
    let onDelete: (() -> Void)?

    var body: some View {
        switch variant {
        case .display:
            displayRow
        case .edit:
            EditTaskCell(
                text: text,
                isNewTask: taskId == nil,
                isFirstRow: isFirstRow,
                onTextChange: { onTextChange?($0) },
                onDelete: onDelete,
                focusedField: focusedField,
                focusTarget: focusTarget
            )
        case .add:
            EditTaskBlankCell(
                isAddEnabled: isAddEnabled,
                onTapAdd: { onTapAdd?() }
            )
        }
    }

    private var displayRow: some View {
        Text(text)
            .font(AppFonts.taskBody)
            .foregroundColor(AppColors.textPrimary)
            .frame(width: AppSpacing.taskTextWidth, alignment: .leading)
            .padding(.leading, AppSpacing.taskTextLeading)
            .padding(.trailing, 14)
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
            .contentShape(Rectangle())
            .onTapGesture {
                onTapTask?()
            }
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
