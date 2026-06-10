import SwiftUI

enum CourseEditorMode {
    case create
    case edit

    var title: String {
        switch self {
        case .create: return "新建课程"
        case .edit: return "编辑课程"
        }
    }
}

enum ExpandedEditorSection {
    case time
    case cycle
}

struct CourseDraft: Equatable {
    var title: String = ""
    var locationRaw: String = ""
    var teacher: String = ""
    var weekday: Int?
    var selectedSections: Set<Int> = []
    var selectedWeeks: Set<Int> = []
    var weekPattern: Course.WeekPattern = .every

    init() {}

    init(course: Course) {
        title = course.name
        locationRaw = course.locationRaw
        teacher = course.teacher
        weekday = course.weekday
        selectedSections = Set(course.startSlot...course.endSlot)
        selectedWeeks = Set(course.weeks)
        weekPattern = course.weekPattern
    }

    func buildCourse(existingID: UUID? = nil, defaultWeek: Int) -> Course? {
        guard let weekday, !selectedSections.isEmpty else { return nil }
        let sortedSections = selectedSections.sorted()
        let resolvedWeeks = selectedWeeks.isEmpty ? [defaultWeek] : selectedWeeks.sorted()
        let status = Course.deriveStatus(name: title, locationRaw: locationRaw, teacher: teacher)

        return Course(
            id: existingID ?? UUID(),
            name: title.trimmingCharacters(in: .whitespacesAndNewlines),
            classroom: "",
            locationRaw: locationRaw.trimmingCharacters(in: .whitespacesAndNewlines),
            teacher: teacher.trimmingCharacters(in: .whitespacesAndNewlines),
            weekday: weekday,
            startSlot: sortedSections.first ?? 1,
            endSlot: sortedSections.last ?? 1,
            weeks: resolvedWeeks,
            weekPattern: weekPattern,
            status: status
        )
    }

    var selectedTimeSummary: String {
        guard let weekday, !selectedSections.isEmpty else { return "未选择" }
        let slots = selectedSections.sorted()
        return "周\(Course.weekdayChinese(weekday)) | \(slots.first ?? 1)-\(slots.last ?? 1)节"
    }

    var selectedCycleSummary: String {
        let resolvedWeeks = selectedWeeks.sorted()
        if resolvedWeeks.isEmpty {
            return "未选择"
        }
        let merged = Course.mergeWeeks(resolvedWeeks)
        guard weekPattern != .every else { return merged }
        return "\(merged) | \(weekPattern.displayText)"
    }
}

struct CreateANewCourseView: View {
    @Environment(\.dismiss) private var dismiss

    let mode: CourseEditorMode
    let currentWeek: Int
    let initialCourse: Course?
    let onSave: (Course) -> Void

    @State private var draft: CourseDraft
    @State private var expandedSection: ExpandedEditorSection?
    @State private var showUnsavedDialog = false
    @State private var reminderMessage: String?

    init(
        mode: CourseEditorMode,
        currentWeek: Int,
        initialCourse: Course? = nil,
        onSave: @escaping (Course) -> Void
    ) {
        self.mode = mode
        self.currentWeek = currentWeek
        self.initialCourse = initialCourse
        self.onSave = onSave
        _draft = State(initialValue: initialCourse.map(CourseDraft.init(course:)) ?? CourseDraft())
    }

    private var initialDraft: CourseDraft {
        initialCourse.map(CourseDraft.init(course:)) ?? CourseDraft()
    }

    private var hasUnsavedChanges: Bool {
        draft != initialDraft
    }

    var body: some View {
        ZStack {
            AppColors.screenBackground.ignoresSafeArea()

            VStack(spacing: 41) {
                TopHeader(
                    variant: .newschedule,
                    title: mode.title,
                    onLeftAction: handleQuitTapped,
                    onRightAction: handleSaveTapped
                )
                .padding(.top, 21)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 2) {
                        inputRow(title: "课程名称", placeholder: "输入课程名称", style: .first, text: $draft.title)

                        inputRow(title: "课程地点", placeholder: "输入课程地点", style: .round, text: $draft.locationRaw)

                        VStack(spacing: 2) {
                            expandableRow(
                                title: "课程时段",
                                selectedValue: draft.selectedTimeSummary,
                                isExpanded: expandedSection == .time,
                                variant: expandedSection == .time
                                    ? .v6_pickerTop(label: "课程时段", selectedValue: draft.selectedTimeSummary == "未选择" ? nil : draft.selectedTimeSummary)
                                    : .v4_pickerRound(label: "课程时段", selectedValue: draft.selectedTimeSummary == "未选择" ? nil : draft.selectedTimeSummary)
                            ) {
                                expandedSection = expandedSection == .time ? nil : .time
                            }

                            if expandedSection == .time {
                                timeExpandedArea
                            }
                        }

                        VStack(spacing: 2) {
                            expandableRow(
                                title: "课程周期",
                                selectedValue: draft.selectedCycleSummary,
                                isExpanded: expandedSection == .cycle,
                                variant: expandedSection == .cycle
                                    ? .v6_pickerTop(label: "课程周期", selectedValue: draft.selectedCycleSummary == "未选择" ? nil : draft.selectedCycleSummary)
                                    : .v4_pickerRound(label: "课程周期", selectedValue: draft.selectedCycleSummary == "未选择" ? nil : draft.selectedCycleSummary)
                            ) {
                                expandedSection = expandedSection == .cycle ? nil : .cycle
                            }

                            if expandedSection == .cycle {
                                cycleExpandedArea
                            }
                        }

                        inputRow(title: "授课教师", placeholder: "输入授课教师", style: .last, text: $draft.teacher)
                    }
                    .frame(width: 356, alignment: .topLeading)
                    .padding(.horizontal, 18.5)
                    .padding(.bottom, 32)
                }
            }

            if showUnsavedDialog {
                WarningPopoverOverlay(
                    onDismiss: { showUnsavedDialog = false }
                ) {
                    QuitWarningPopover(
                        onCancel: { showUnsavedDialog = false },
                        onConfirmExit: {
                            showUnsavedDialog = false
                            dismiss()
                        }
                    )
                }
            }

            if let reminderMessage {
                InputReminderOverlay(message: reminderMessage)
            }
        }
        .presentationBackground(AppColors.screenBackground)
    }

    private func handleQuitTapped() {
        if hasUnsavedChanges {
            showUnsavedDialog = true
        } else {
            dismiss()
        }
    }

    private func handleSaveTapped() {
        if draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showReminder("请输入课程名称！")
            return
        }

        guard let course = draft.buildCourse(existingID: initialCourse?.id, defaultWeek: currentWeek) else {
            showReminder("请选择课程时段！")
            return
        }
        onSave(course)
        dismiss()
    }

    private func showReminder(_ message: String) {
        reminderMessage = message

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            if reminderMessage == message {
                reminderMessage = nil
            }
        }
    }

    @ViewBuilder
    private func inputRow(title: String, placeholder: String, style: InputRowStyle, text: Binding<String>) -> some View {
        let rowVariant = rowVariant(for: style, title: title)
        ZStack {
            NewScheduleRow(variant: rowVariant, onTap: {})

            HStack(spacing: 0) {
                Spacer()
                TextField(
                    "",
                    text: text,
                    prompt: Text(placeholder)
                        .font(.custom("MiSans-Regular", size: 16))
                        .foregroundColor(.gray)
                )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.custom("MiSans-Regular", size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 170)
            }
            .padding(.leading, 140)
            .padding(.trailing, 36)
        }
        .frame(maxWidth: .infinity)
    }

    private func rowVariant(for style: InputRowStyle, title: String) -> NewScheduleRow.Variant {
        switch style {
        case .first:
            return .v1_textFieldBottom(label: title, placeholder: "")
        case .round:
            return .v2_textFieldRound(label: title, placeholder: "")
        case .last:
            return .v3_textFieldTop(label: title, placeholder: "")
        }
    }

    @ViewBuilder
    private func expandableRow(
        title: String,
        selectedValue: String,
        isExpanded: Bool,
        variant: NewScheduleRow.Variant,
        action: @escaping () -> Void
    ) -> some View {
        NewScheduleRow(
            variant: variant,
            onTap: action
        )
        .frame(maxWidth: .infinity)
    }

    private var timeExpandedArea: some View {
        ZStack(alignment: .topLeading) {
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 15,
                bottomTrailingRadius: 15,
                topTrailingRadius: 0
            )
            .fill(AppColors.dateButtonUnselected)
            .frame(width: 356, height: 251)

            VStack(alignment: .leading, spacing: 15) {
                SingleWeekdaySelector(selectedWeekday: $draft.weekday)
                CourseSessionSelectionSection(totalSessions: 12, selected: $draft.selectedSections)
            }
            .frame(width: 239, height: 215, alignment: .leading)
            .padding(.leading, 58)
            .padding(.top, 18)
        }
        .frame(width: 356, height: 251, alignment: .topLeading)
    }

    private var cycleExpandedArea: some View {
        ZStack(alignment: .topLeading) {
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 15,
                bottomTrailingRadius: 15,
                topTrailingRadius: 0
            )
            .fill(AppColors.dateButtonUnselected)
            .frame(width: 356, height: 210)

            CycleSelectionSection(total: 20, selected: $draft.selectedWeeks)
                .padding(.leading, 34)
                .padding(.top, 24)
        }
        .frame(width: 356, height: 210, alignment: .topLeading)
    }
}

private enum InputRowStyle {
    case first
    case round
    case last
}

private struct SingleWeekdaySelector: View {
    @Binding var selectedWeekday: Int?

    private let weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { index in
                    weekdayCell(index)
                }
            }
            HStack(spacing: 2) {
                ForEach(5..<7, id: \.self) { index in
                    weekdayCell(index)
                }
            }
        }
    }

    private func weekdayCell(_ index: Int) -> some View {
        DateSelection(
            weekday: weekdays[index],
            isSelected: selectedWeekday == index + 1
        )
        .onTapGesture {
            selectedWeekday = (selectedWeekday == index + 1) ? nil : index + 1
        }
    }
}

#Preview {
    CreateANewCourseView(
        mode: .create,
        currentWeek: 10,
        onSave: { _ in }
    )
}
