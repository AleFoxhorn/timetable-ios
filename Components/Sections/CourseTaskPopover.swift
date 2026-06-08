import SwiftUI

struct CourseTaskPopover: View {
    enum TaskFieldFocus: Hashable {
        case draft
        case existing(UUID)
    }

    let tasks: [CourseTask]
    let editingTaskId: UUID?
    let editingTaskText: String
    let hasDraftNewTask: Bool
    let draftTaskText: String
    let onAddTask: () -> Void
    let onTapTask: (UUID) -> Void
    let onChangeDraftText: (String) -> Void
    let onChangeTaskText: (String) -> Void
    let onDeleteTask: (UUID) -> Void
    let onCommitDraft: () -> Void
    let onCommitTask: (UUID) -> Void

    @FocusState private var focusedField: TaskFieldFocus?

    var body: some View {
        ZStack(alignment: .topLeading) {
            EditCourseBoardCell()

            ZStack(alignment: .topLeading) {
                AppColors.taskPopoverInnerFill
                    .contentShape(Rectangle())
                    .onTapGesture {
                        commitCurrentFocus()
                    }

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppSpacing.taskRowOverlap) {
                            ForEach(Array(tasks.enumerated()), id: \.element.id) { index, task in
                                TaskListCell(
                                    taskId: task.id,
                                    text: editingTaskId == task.id ? editingTaskText : task.text,
                                    variant: editingTaskId == task.id ? .edit : .display,
                                    isFirstRow: index == 0 && !hasDraftNewTask,
                                    isAddEnabled: false,
                                    focusedField: $focusedField,
                                    focusTarget: .existing(task.id),
                                    onTapTask: {
                                        commitCurrentFocus()
                                        onTapTask(task.id)
                                        focusedField = .existing(task.id)
                                    },
                                    onTapAdd: nil,
                                    onTextChange: { onChangeTaskText($0) },
                                    onDelete: { onDeleteTask(task.id) }
                                )
                            }

                            if hasDraftNewTask {
                                TaskListCell(
                                    taskId: nil,
                                    text: draftTaskText,
                                    variant: .edit,
                                    isFirstRow: tasks.isEmpty,
                                    isAddEnabled: false,
                                    focusedField: $focusedField,
                                    focusTarget: .draft,
                                    onTapTask: nil,
                                    onTapAdd: nil,
                                    onTextChange: { onChangeDraftText($0) },
                                    onDelete: nil
                                )
                            }
                        }
                    }

                    Spacer(minLength: 0)

                    addRow
                }
            }
            .frame(width: AppSpacing.taskPopoverInnerWidth, height: 265, alignment: .top)
            .clipShape(RoundedRectangle(cornerRadius: CardCornerRadius.taskPopoverInner))
            .offset(x: AppSpacing.taskPopoverInnerLeading, y: AppSpacing.taskPopoverInnerTop)
        }
        .frame(width: AppSpacing.taskPopoverOuterWidth, height: 284)
        .onChange(of: focusedField, initial: false) { oldValue, newValue in
            guard oldValue != newValue else { return }
            commit(field: oldValue)
        }
        .onAppear {
            if hasDraftNewTask {
                focusedField = .draft
            } else if let editingTaskId {
                focusedField = .existing(editingTaskId)
            }
        }
        .onChange(of: hasDraftNewTask, initial: false) { _, isActive in
            if isActive {
                focusedField = .draft
            }
        }
        .onChange(of: editingTaskId, initial: false) { _, newValue in
            if let newValue {
                focusedField = .existing(newValue)
            }
        }
    }

    func commitCurrentFocus() {
        let current = focusedField
        focusedField = nil
        commit(field: current)
    }

    private func commit(field: TaskFieldFocus?) {
        switch field {
        case .draft:
            onCommitDraft()
        case .existing(let id):
            onCommitTask(id)
        case .none:
            break
        }
    }

    private var addRow: some View {
        TaskListCell(
            taskId: nil,
            text: "",
            variant: .add,
            isFirstRow: false,
            isAddEnabled: !hasDraftNewTask,
            focusedField: $focusedField,
            focusTarget: nil,
            onTapTask: nil,
            onTapAdd: {
                commitCurrentFocus()
                onAddTask()
                focusedField = .draft
            },
            onTextChange: nil,
            onDelete: nil
        )
    }
}
