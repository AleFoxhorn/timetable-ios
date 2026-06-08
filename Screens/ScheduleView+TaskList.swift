import SwiftUI

struct TaskListOverlay: View {
    @Bindable var viewModel: ScheduleViewModel

    var body: some View {
        if let instance = viewModel.activeTaskPopoverCourseCardInstance {
            ZStack {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.commitActiveTaskEditorIfNeeded()
                        viewModel.dismissTaskPopover()
                    }

                CourseTaskPopover(
                    tasks: viewModel.activeCourseTasks,
                    editingTaskId: viewModel.editingTaskID,
                    editingTaskText: viewModel.editingTaskText,
                    draftTaskText: viewModel.draftTaskText,
                    onActivateDraft: {
                        viewModel.beginDraftTask(for: instance.id)
                    },
                    onTapTask: { taskID in
                        viewModel.startEditingTask(taskID)
                    },
                    onChangeDraftText: { text in
                        viewModel.updateDraftTaskText(text)
                    },
                    onChangeTaskText: { text in
                        viewModel.updateEditingTaskText(text)
                    },
                    onDeleteTask: { taskID in
                        viewModel.deleteTask(taskID)
                    },
                    onSubmitDraft: {
                        viewModel.commitDraftTaskIfNeeded()
                    },
                    onCommitTask: { taskID in
                        viewModel.commitEditingTaskIfNeeded(taskID)
                    }
                )
            }
        }
    }
}
