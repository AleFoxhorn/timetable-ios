import SwiftUI

struct EditTaskBlankCell: View {
    let text: String
    let isAddEnabled: Bool
    let focusedField: FocusState<CourseTaskPopover.TaskFieldFocus?>.Binding
    let focusTarget: CourseTaskPopover.TaskFieldFocus?
    let onTapBlank: () -> Void
    let onTextChange: (String) -> Void
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
                .contentShape(Rectangle())
                .onTapGesture(perform: onTapBlank)

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
            .frame(width: 158, height: AppSpacing.taskRowHeight, alignment: .leading)
            .offset(x: 50, y: 0)

            TaskButtonPlus(onTap: onTapAdd)
                .disabled(!isAddEnabled)
                .offset(x: AppSpacing.taskAddButtonLeading, y: 10)
        }
        .frame(width: AppSpacing.taskPopoverInnerWidth, height: AppSpacing.taskAddRowHeight, alignment: .leading)
    }
}

#Preview {
    PreviewWrapper()
        .padding()
        .background(Color.black)
}

private struct PreviewWrapper: View {
    @FocusState private var focusedField: CourseTaskPopover.TaskFieldFocus?

    var body: some View {
        EditTaskBlankCell(
            text: "",
            isAddEnabled: true,
            focusedField: $focusedField,
            focusTarget: .draft,
            onTapBlank: {},
            onTextChange: { _ in },
            onTapAdd: {}
        )
    }
}
