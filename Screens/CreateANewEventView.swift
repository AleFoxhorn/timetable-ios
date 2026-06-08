import SwiftUI

enum EventEditorMode {
    case create
    case edit

    var title: String {
        switch self {
        case .create:
            return "新建事项"
        case .edit:
            return "编辑事项"
        }
    }
}

struct EventDraft: Equatable {
    var title: String = ""
    var location: String = ""
    var selectedDateIndex: Int = 0
    var repeatRule: ScheduleEvent.RepeatRule = .none
    var startTime: Date = EventDraft.defaultTime(hour: 9, minute: 0)
    var endTime: Date = EventDraft.defaultTime(hour: 10, minute: 0)
    var notes: String = ""
    var hasConfiguredTime: Bool = false

    init() {}

    init(event: ScheduleEvent, weekDates: [Date]) {
        title = event.title
        location = event.location
        repeatRule = event.repeatRule
        notes = event.notes
        hasConfiguredTime = true
        selectedDateIndex = weekDates.firstIndex(where: {
            Calendar.current.isDate($0, inSameDayAs: event.date)
        }) ?? max(0, event.weekday - 1)
        startTime = EventDraft.timeDate(from: event.startTime) ?? EventDraft.defaultTime(hour: 9, minute: 0)
        endTime = EventDraft.timeDate(from: event.endTime) ?? EventDraft.defaultTime(hour: 10, minute: 0)
    }

    func buildEvent(existingID: UUID? = nil, currentWeek: Int, totalWeeks: Int, weekDates: [Date]) -> ScheduleEvent {
        let selectedDate = weekDates[max(0, min(selectedDateIndex, weekDates.count - 1))]
        let startTimeText = EventDraft.timeFormatter.string(from: startTime)
        let endTimeText = EventDraft.timeFormatter.string(from: endTime)

        return ScheduleEvent(
            id: existingID ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            date: selectedDate,
            startTime: startTimeText,
            endTime: endTimeText,
            repeatRule: repeatRule,
            weeks: ScheduleEvent.makeWeeks(
                repeatRule: repeatRule,
                currentWeek: currentWeek,
                totalWeeks: totalWeeks
            ),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    func timeSummary(weekDates: [Date]) -> String {
        guard hasConfiguredTime else { return "未选择" }
        guard weekDates.indices.contains(selectedDateIndex) else { return "未选择" }
        let date = weekDates[selectedDateIndex]
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        let start = EventDraft.timeFormatter.string(from: startTime)
        let end = EventDraft.timeFormatter.string(from: endTime)
        return "\(month)月\(day)日 | \(start)-\(end)"
    }

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static func timeDate(from string: String) -> Date? {
        timeFormatter.date(from: string)
    }

    private static func defaultTime(hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let base = calendar.startOfDay(for: Date())
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }
}

struct CreateANewEventView: View {
    let currentWeek: Int
    let currentDate: Date
    let onSave: (ScheduleEvent) -> Void
    let onValidate: (ScheduleEvent) -> String?

    var body: some View {
        EventEditorScreen(
            mode: .create,
            currentWeek: currentWeek,
            currentDate: currentDate,
            initialEvent: nil,
            onSave: onSave,
            onValidate: onValidate
        )
    }
}

struct EventEditorScreen: View {
    @Environment(\.dismiss) private var dismiss

    let mode: EventEditorMode
    let currentWeek: Int
    let currentDate: Date
    let initialEvent: ScheduleEvent?
    let onSave: (ScheduleEvent) -> Void
    let onValidate: (ScheduleEvent) -> String?

    @State private var draft: EventDraft
    @State private var isTimeExpanded: Bool
    @State private var showUnsavedDialog = false
    @State private var validationMessage: String?
    @State private var activeTimeField: EventTimeField?

    private let weekDates: [Date]
    private let totalWeeks = 20

    init(
        mode: EventEditorMode,
        currentWeek: Int,
        currentDate: Date,
        initialEvent: ScheduleEvent?,
        onSave: @escaping (ScheduleEvent) -> Void,
        onValidate: @escaping (ScheduleEvent) -> String?
    ) {
        self.mode = mode
        self.currentWeek = currentWeek
        self.currentDate = currentDate
        self.initialEvent = initialEvent
        self.onSave = onSave
        self.onValidate = onValidate

        let weekDates = EventEditorScreen.makeWeekDates(from: currentDate)
        self.weekDates = weekDates
        let draft = initialEvent.map { EventDraft(event: $0, weekDates: weekDates) } ?? EventDraft()
        _draft = State(initialValue: draft)
        _isTimeExpanded = State(initialValue: initialEvent != nil)
    }

    private var initialDraft: EventDraft {
        initialEvent.map { EventDraft(event: $0, weekDates: weekDates) } ?? EventDraft()
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
                        inputRow(
                            title: "事项名称",
                            placeholder: "输入事项名称",
                            style: .top,
                            text: $draft.title
                        )

                        inputRow(
                            title: "事项地点",
                            placeholder: "输入事项地点",
                            style: .round,
                            text: $draft.location
                        )

                        VStack(spacing: 2) {
                            expandableRow(
                                title: "事项时间",
                                selectedValue: draft.timeSummary(weekDates: weekDates),
                                isExpanded: isTimeExpanded
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isTimeExpanded.toggle()
                                }
                                if isTimeExpanded {
                                    draft.hasConfiguredTime = true
                                }
                            }

                            if isTimeExpanded {
                                timeExpandedArea
                            }
                        }

                        notesRow
                    }
                    .frame(width: 356, alignment: .topLeading)
                    .padding(.horizontal, 18.5)
                    .padding(.bottom, 32)
                }
            }

            if showUnsavedDialog {
                AppColors.modalScrim
                    .ignoresSafeArea()
                    .onTapGesture { showUnsavedDialog = false }

                EventUnsavedChangesDialogView(
                    onConfirmExit: {
                        showUnsavedDialog = false
                        dismiss()
                    },
                    onCancel: { showUnsavedDialog = false },
                    onDismissByBackgroundTap: { showUnsavedDialog = false }
                )
            }
        }
        .sheet(item: $activeTimeField) { field in
            EventTimePickerSheet(
                title: field.title,
                selection: binding(for: field)
            )
            .presentationDetents([.height(280)])
            .presentationDragIndicator(.visible)
        }
        .alert(validationMessage ?? "", isPresented: validationAlertBinding) {
            Button("确定", role: .cancel) {}
        }
        .presentationBackground(AppColors.screenBackground)
    }

    private var validationAlertBinding: Binding<Bool> {
        Binding(
            get: { validationMessage != nil },
            set: { newValue in
                if !newValue {
                    validationMessage = nil
                }
            }
        )
    }

    @ViewBuilder
    private func inputRow(
        title: String,
        placeholder: String,
        style: EventInputRowStyle,
        text: Binding<String>
    ) -> some View {
        let rowVariant = rowVariant(for: style, title: title, text: text.wrappedValue, placeholder: placeholder)

        ZStack {
            NewScheduleRow(variant: rowVariant, onTap: {})

            HStack(spacing: 0) {
                Spacer()
                TextField("", text: text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.custom("MiSans-Regular", size: 16))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 175)
            }
            .padding(.leading, 140)
            .padding(.trailing, 36)
        }
        .frame(maxWidth: .infinity)
    }

    private func expandableRow(
        title: String,
        selectedValue: String,
        isExpanded: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let value = selectedValue == "未选择" ? nil : selectedValue
        let variant: NewScheduleRow.Variant = isExpanded
            ? .v6_pickerTop(label: title, selectedValue: value)
            : .v4_pickerRound(label: title, selectedValue: value)

        return NewScheduleRow(variant: variant, onTap: action)
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
            .frame(width: 356, height: 226)

            VStack(alignment: .leading, spacing: 12) {
                EventSelectionSection(
                    dates: weekDates.map {
                        EventDateInfo(
                            weekday: EventEditorScreen.weekdayFormatter.string(from: $0).uppercased(),
                            day: Calendar.current.component(.day, from: $0)
                        )
                    },
                    selected: selectedDateBinding
                )
                .frame(width: 335)

                HStack(spacing: 6) {
                    Button(action: { draft.repeatRule = .none }) {
                        EventCycleTypeButton(label: "不重复", isSelected: draft.repeatRule == .none)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded { draft.hasConfiguredTime = true })

                    Button(action: { draft.repeatRule = .weekly }) {
                        EventCycleTypeButton(label: "每周", isSelected: draft.repeatRule == .weekly)
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded { draft.hasConfiguredTime = true })
                }

                VStack(spacing: 4) {
                    EventTimeSelectionRow(
                        title: "开始",
                        value: EventDraft.timeFormatter.string(from: draft.startTime)
                    ) {
                        activeTimeField = .start
                    }

                    EventTimeSelectionRow(
                        title: "结束",
                        value: EventDraft.timeFormatter.string(from: draft.endTime)
                    ) {
                        activeTimeField = .end
                    }
                }
            }
            .padding(.leading, 10)
            .padding(.top, 12)
        }
        .frame(width: 356, height: 226, alignment: .topLeading)
    }

    private var notesRow: some View {
        ZStack(alignment: .topLeading) {
            NewScheduleRow(
                variant: .v5_notesTop(label: "事项备注：", placeholder: draft.notes.isEmpty ? "……" : draft.notes),
                onTap: {}
            )

            TextEditor(text: $draft.notes)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .font(.custom("MiSans-Regular", size: 16))
                .foregroundColor(.black)
                .frame(width: 278, height: 34)
                .padding(.leading, 33)
                .padding(.top, 39)

            if draft.notes.isEmpty {
                Text("……")
                    .font(.custom("MiSans-Regular", size: 16))
                    .foregroundColor(.black.opacity(0.75))
                    .padding(.leading, 37)
                    .padding(.top, 47)
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var selectedDateBinding: Binding<Set<Int>> {
        Binding(
            get: { [draft.selectedDateIndex] },
            set: { newValue in
                if let selectedIndex = newValue.sorted().last {
                    draft.selectedDateIndex = selectedIndex
                    draft.hasConfiguredTime = true
                }
            }
        )
    }

    private func binding(for field: EventTimeField) -> Binding<Date> {
        Binding(
            get: {
                switch field {
                case .start:
                    return draft.startTime
                case .end:
                    return draft.endTime
                }
            },
            set: { newValue in
                switch field {
                case .start:
                    draft.startTime = newValue
                case .end:
                    draft.endTime = newValue
                }
                draft.hasConfiguredTime = true
            }
        )
    }

    private func handleQuitTapped() {
        if hasUnsavedChanges {
            showUnsavedDialog = true
        } else {
            dismiss()
        }
    }

    private func handleSaveTapped() {
        guard draft.hasConfiguredTime else {
            validationMessage = "请选择事项时间"
            return
        }

        let event = draft.buildEvent(
            existingID: initialEvent?.id,
            currentWeek: currentWeek,
            totalWeeks: totalWeeks,
            weekDates: weekDates
        )

        if let message = onValidate(event) {
            validationMessage = message
            return
        }

        onSave(event)
        dismiss()
    }

    private func rowVariant(
        for style: EventInputRowStyle,
        title: String,
        text: String,
        placeholder: String
    ) -> NewScheduleRow.Variant {
        let display = text.isEmpty ? placeholder : ""
        switch style {
        case .top:
            return .v3_textFieldTop(label: title, placeholder: display)
        case .round:
            return .v2_textFieldRound(label: title, placeholder: display)
        }
    }

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private static func makeWeekDates(from currentDate: Date) -> [Date] {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let mondayOffset = (weekday + 5) % 7
        let weekStart = calendar.date(
            byAdding: .day,
            value: -mondayOffset,
            to: calendar.startOfDay(for: currentDate)
        ) ?? currentDate
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }
}

private enum EventInputRowStyle {
    case top
    case round
}

private enum EventTimeField: Identifiable {
    case start
    case end

    var id: String {
        switch self {
        case .start:
            return "start"
        case .end:
            return "end"
        }
    }

    var title: String {
        switch self {
        case .start:
            return "开始时间"
        case .end:
            return "结束时间"
        }
    }
}

private struct EventTimeSelectionRow: View {
    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.custom("MiSans-Regular", size: 18))
                    .foregroundColor(.white)
                Spacer()
                Text(value)
                    .font(.custom("Apple Braille", size: 16))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 18)
            .frame(width: 334, height: 52)
            .background(AppColors.surfaceInverse)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

private struct EventTimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    @Binding var selection: Date

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(title)
                    .font(.custom("MiSans-Medium", size: 18))
                Spacer()
                Button("完成") {
                    dismiss()
                }
                .font(.custom("MiSans-Regular", size: 16))
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            DatePicker(
                "",
                selection: $selection,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
        }
        .presentationBackground(.ultraThinMaterial)
    }
}

private struct EventUnsavedChangesDialogView: View {
    let onConfirmExit: () -> Void
    let onCancel: () -> Void
    let onDismissByBackgroundTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("尚未保存")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, 18)

            Text("当前修改尚未保存，确认退出吗？")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textPrimary.opacity(0.7))
                .padding(.top, 8)
                .padding(.bottom, 18)

            Divider()

            HStack(spacing: 0) {
                Button(action: onCancel) {
                    Text("取消")
                        .font(.system(size: 17))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(
                            minWidth: 0,
                            idealWidth: nil,
                            maxWidth: .infinity,
                            minHeight: 50,
                            idealHeight: nil,
                            maxHeight: nil,
                            alignment: .center
                        )
                }

                Divider()

                Button(action: onConfirmExit) {
                    Text("退出")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(AppColors.textPrimary)
                        .frame(
                            minWidth: 0,
                            idealWidth: nil,
                            maxWidth: .infinity,
                            minHeight: 50,
                            idealHeight: nil,
                            maxHeight: nil,
                            alignment: .center
                        )
                }
            }
        }
        .frame(width: 238)
        .background(AppColors.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .onTapGesture {}
    }
}

#Preview {
    CreateANewEventView(
        currentWeek: 10,
        currentDate: Date(),
        onSave: { _ in },
        onValidate: { _ in nil }
    )
}
