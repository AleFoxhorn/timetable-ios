import SwiftUI
import Observation

struct MainScreen: View {
    @State private var scheduleViewModel = ScheduleViewModel()
    @State private var timetableViewModel = TimetableViewModel()
    @State private var path: [TimetableRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            rootContent
                .navigationBarBackButtonHidden(true)
                .navigationDestination(for: TimetableRoute.self) { route in
                    switch route {
                    case .selectFirstWeek:
                        SelectFirstWeekView(
                            timetableViewModel: timetableViewModel,
                            onBack: { path.removeLast() },
                            onSelectWeek: {
                                path.append(.semesterPreview)
                            }
                        )
                    case .semesterPreview:
                        SemesterPreviewView(
                            timetableViewModel: timetableViewModel,
                            onBack: { path.removeLast() },
                            onConfirm: {
                                if timetableViewModel.commit(using: scheduleViewModel) {
                                    syncScheduleWithTimetable()
                                    path.removeAll()
                                }
                            }
                        )
                    }
                }
        }
        .onAppear(perform: syncScheduleWithTimetable)
    }

    @ViewBuilder
    private var rootContent: some View {
        if !timetableViewModel.hasConfiguredTimetable {
            OnboardingScheduleView(onCreateSchedule: beginCreateScheduleFlow)
        } else if scheduleViewModel.courses.isEmpty {
            BlankScheduleView(
                scheduleViewModel: scheduleViewModel,
                timetableViewModel: timetableViewModel,
                onCreateSchedule: beginCreateScheduleFlow
            )
        } else {
            ScheduleScreen(
                viewModel: scheduleViewModel,
                timetableViewModel: timetableViewModel,
                onCreateSchedule: beginCreateScheduleFlow
            )
        }
    }

    private func beginCreateScheduleFlow() {
        timetableViewModel.beginDraft()
        path = [.selectFirstWeek]
    }

    private func syncScheduleWithTimetable() {
        guard let config = timetableViewModel.activeConfig else { return }
        scheduleViewModel.applyTimetableConfig(config)
    }
}

#Preview {
    MainScreen()
}

private enum TimetableRoute: Hashable {
    case selectFirstWeek
    case semesterPreview
}

@Observable
final class TimetableViewModel {
    private let repository = TimetableRepository()
    let totalWeeks = 20

    var activeConfig: TimetableConfig?
    var draftSemesterStartMonday: Date?

    init() {
        activeConfig = repository.load()
    }

    var hasConfiguredTimetable: Bool {
        activeConfig != nil
    }

    var currentCandidateWeekIndex: Int {
        candidateWeeks.count / 2
    }

    var currentWeekTitle: String {
        guard let config = activeConfig else { return "第1周" }
        switch weekDisplayState(for: Date(), semesterStartMonday: config.semesterStartMonday) {
        case .beforeStart:
            return "未开学"
        case .afterEnd:
            return "学期已结束"
        case .inSemester(let week):
            return "第\(week)周"
        }
    }

    var candidateWeeks: [[Date]] {
        let currentMonday = monday(for: Date())
        return (-26...26).compactMap { offset in
            guard let monday = Calendar.current.date(byAdding: .day, value: offset * 7, to: currentMonday) else {
                return nil
            }
            return weekDates(startingAt: monday)
        }
    }

    var previewWeeks: [[Date]] {
        guard let startMonday = draftSemesterStartMonday else { return [] }
        return (0..<totalWeeks).compactMap { offset in
            guard let monday = Calendar.current.date(byAdding: .day, value: offset * 7, to: startMonday) else {
                return nil
            }
            return weekDates(startingAt: monday)
        }
    }

    func beginDraft() {
        draftSemesterStartMonday = monday(for: Date())
    }

    func selectWeek(_ dates: [Date]) {
        guard let first = dates.first else { return }
        draftSemesterStartMonday = monday(for: first)
    }

    func commit(using scheduleViewModel: ScheduleViewModel) -> Bool {
        guard let startMonday = draftSemesterStartMonday else { return false }

        let previousConfig = activeConfig
        let newConfig = TimetableConfig(
            id: previousConfig?.id ?? UUID(),
            semesterStartMonday: startMonday
        )

        do {
            try repository.save(newConfig)
            do {
                try scheduleViewModel.clearAllCourses()
                try scheduleViewModel.clearAllEvents()
                activeConfig = newConfig
                scheduleViewModel.applyTimetableConfig(newConfig)
                return true
            } catch {
                if let previousConfig {
                    try? repository.save(previousConfig)
                    activeConfig = previousConfig
                    scheduleViewModel.applyTimetableConfig(previousConfig)
                } else {
                    try? repository.delete()
                    activeConfig = nil
                }
                return false
            }
        } catch {
            return false
        }
    }

    func rowStyle(for dates: [Date], inPreview: Bool, rowIndex: Int) -> (SelectWeekTitle.Style, SelectWeekRow.FillStyle, SelectWeekRow.CornerStyle) {
        let isCurrent = isCurrentWeek(dates)
        let titleStyle: SelectWeekTitle.Style
        if isCurrent {
            titleStyle = .filled
        } else if inPreview {
            titleStyle = .numbered(rowIndex + 1)
        } else {
            titleStyle = .empty
        }

        let fillStyle: SelectWeekRow.FillStyle = isCurrent ? .grey : .white
        let cornerStyle: SelectWeekRow.CornerStyle = rowIndex == 0 ? .square : .round
        return (titleStyle, fillStyle, cornerStyle)
    }

    private func isCurrentWeek(_ dates: [Date]) -> Bool {
        guard let currentMonday = dates.first else { return false }
        return Calendar.current.isDate(monday(for: Date()), inSameDayAs: currentMonday)
    }

    private func monday(for date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let mondayOffset = (weekday + 5) % 7
        let startOfDay = calendar.startOfDay(for: date)
        return calendar.date(byAdding: .day, value: -mondayOffset, to: startOfDay) ?? startOfDay
    }

    private func weekDates(startingAt monday: Date) -> [Date] {
        (0..<7).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: offset, to: monday)
        }
    }

    private func weekDisplayState(for date: Date, semesterStartMonday: Date) -> WeekDisplayState {
        let start = monday(for: semesterStartMonday)
        let days = Calendar.current.dateComponents([.day], from: start, to: Calendar.current.startOfDay(for: date)).day ?? 0
        if days < 0 {
            return .beforeStart
        }

        let week = days / 7 + 1
        if week > totalWeeks {
            return .afterEnd
        }

        return .inSemester(week)
    }

    private enum WeekDisplayState {
        case beforeStart
        case afterEnd
        case inSemester(Int)
    }
}

struct TimetableRepository {
    private let storageURL: URL = {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return documents.appendingPathComponent("timetable_config.json")
    }()

    func load() -> TimetableConfig? {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: storageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(TimetableConfig.self, from: data)
        } catch {
            print("Failed to load timetable_config.json: \(error)")
            return nil
        }
    }

    func save(_ config: TimetableConfig) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(config)
        try data.write(to: storageURL, options: [.atomic])
    }

    func delete() throws {
        if FileManager.default.fileExists(atPath: storageURL.path) {
            try FileManager.default.removeItem(at: storageURL)
        }
    }
}

struct OnboardingScheduleView: View {
    let onCreateSchedule: () -> Void

    private let colW: CGFloat = 45
    private let colGap: CGFloat = 1
    private let gridW: CGFloat = 321
    private let blockH: CGFloat = 191
    private let leftAxisW: CGFloat = 57
    private let scheduleAreaH: CGFloat = 603

    var body: some View {
        ZStack {
            AppColors.screenBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                TopHeader(
                    variant: .buildnewsheet,
                    onLeftAction: onCreateSchedule,
                    onRightAction: {}
                )
                .frame(width: 393, height: 27)

                WeekDateBar(month: currentMonthLabel, days: currentWeekDayInfos)
                    .frame(width: 378, height: 40)
                    .padding(.top, 15)

                HStack(alignment: .top, spacing: 0) {
                    TimeAxis(times: MockData.times)
                        .frame(width: leftAxisW, height: scheduleAreaH)
                    emptySlotGrid
                }
                .frame(width: 378, height: scheduleAreaH)
                .padding(.top, 15)

                HStack(spacing: 0) {
                    Color.clear.frame(width: leftAxisW)
                    BottomToggleBar(mode: .courses, onToggle: {}, onAdd: {})
                }
                .frame(width: 378, height: 55)
                .padding(.top, 15)

                Spacer(minLength: 17)
            }
            .padding(.top, AppSpacing.semesterScreenTopPadding)
        }
    }

    private var emptySlotGrid: some View {
        VStack(spacing: 15) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(spacing: 1) {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack(spacing: colGap) {
                            ForEach(0..<7, id: \.self) { _ in
                                EmptySlotCard().frame(width: colW, height: 47)
                            }
                        }
                    }
                }
                .frame(width: gridW, height: blockH, alignment: .topLeading)
            }
        }
        .frame(width: gridW, height: scheduleAreaH, alignment: .topLeading)
    }

    private var currentWeekDayInfos: [DayInfo] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        let calendar = Calendar.current
        let start = monday(for: Date())
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return DayInfo(
                weekday: formatter.string(from: date).uppercased(),
                day: calendar.component(.day, from: date),
                isToday: calendar.isDateInToday(date)
            )
        }
    }

    private var currentMonthLabel: String {
        let month = Calendar.current.component(.month, from: Date())
        return "\(month)\n月"
    }

    private func monday(for date: Date) -> Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        let offset = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -offset, to: calendar.startOfDay(for: date)) ?? date
    }
}

struct SelectFirstWeekView: View {
    @Bindable var timetableViewModel: TimetableViewModel
    let onBack: () -> Void
    let onSelectWeek: () -> Void

    var body: some View {
        ZStack {
            AppColors.screenBackground.ignoresSafeArea()

            VStack(spacing: 15) {
                TopHeader(
                    variant: .choosethefirstweek,
                    onLeftAction: onBack,
                    onRightAction: {}
                )
                .padding(.top, AppSpacing.semesterScreenTopPadding)

                WeekHeaderRow(weekdays: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"])

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: AppSpacing.semesterWeekRowGap) {
                            ForEach(Array(timetableViewModel.candidateWeeks.enumerated()), id: \.offset) { index, week in
                                let style = timetableViewModel.rowStyle(for: week, inPreview: false, rowIndex: index)
                                SelectWeekRowSection(
                                    titleStyle: style.0,
                                    dates: week,
                                    fillStyle: style.1,
                                    cornerStyle: style.2,
                                    onTap: {
                                        timetableViewModel.selectWeek(week)
                                        onSelectWeek()
                                    }
                                )
                                .id(index)
                            }
                        }
                        .frame(width: 367)
                        .padding(.bottom, 24)
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            proxy.scrollTo(timetableViewModel.currentCandidateWeekIndex, anchor: .center)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct SemesterPreviewView: View {
    @Bindable var timetableViewModel: TimetableViewModel
    let onBack: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            AppColors.screenBackground.ignoresSafeArea()

            VStack(spacing: 15) {
                TopHeader(
                    variant: .preview,
                    onLeftAction: onBack,
                    onRightAction: onConfirm
                )
                .padding(.top, AppSpacing.semesterScreenTopPadding)

                WeekHeaderRow(weekdays: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"])

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.semesterWeekRowGap) {
                        ForEach(Array(timetableViewModel.previewWeeks.enumerated()), id: \.offset) { index, week in
                            let style = timetableViewModel.rowStyle(for: week, inPreview: true, rowIndex: index)
                            SelectWeekRowSection(
                                titleStyle: style.0,
                                dates: week,
                                fillStyle: style.1,
                                cornerStyle: style.2,
                                onTap: {}
                            )
                        }
                    }
                    .frame(width: 367)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct BlankScheduleView: View {
    private enum WeekSwipeDirection {
        case previous
        case next
    }

    @Bindable var scheduleViewModel: ScheduleViewModel
    @Bindable var timetableViewModel: TimetableViewModel
    let onCreateSchedule: () -> Void

    @State private var mode: DisplayMode = .courses
    @State private var activeSheet: BlankScheduleSheet?
    @State private var weekSwipeDirection: WeekSwipeDirection = .next

    private let colW: CGFloat = 45
    private let colGap: CGFloat = 1
    private let gridW: CGFloat = 321
    private let blockH: CGFloat = 191
    private let leftAxisW: CGFloat = 57
    private let scheduleAreaH: CGFloat = 603
    private let swipeThreshold: CGFloat = 40

    var body: some View {
        ZStack {
            AppColors.screenBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                TopHeader(
                    variant: .weeknumber,
                    title: scheduleViewModel.selectedWeekTitle,
                    onLeftAction: {
                        scheduleViewModel.clearFlippedCourseCard()
                        onCreateSchedule()
                    },
                    onRightAction: {
                        scheduleViewModel.clearFlippedCourseCard()
                        activeSheet = .createCourse
                    }
                )
                .frame(width: 393, height: 27)

                WeekDateBar(month: scheduleViewModel.selectedWeekMonthLabel, days: scheduleViewModel.selectedWeekDayInfos)
                    .frame(width: 378, height: 40)
                    .padding(.top, 15)

                ZStack {
                    blankScheduleContent
                        .id(scheduleViewModel.selectedWeek)
                        .transition(weekContentTransition)
                }
                .frame(width: 378, height: scheduleAreaH + 70, alignment: .topLeading)
                .padding(.top, 15)
                .animation(.easeInOut(duration: 0.28), value: scheduleViewModel.selectedWeek)
                .gesture(weekSwipeGesture)

                Spacer(minLength: 17)
            }
            .padding(.top, AppSpacing.semesterScreenTopPadding)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .createCourse:
                CreateANewCourseView(
                    mode: .create,
                    currentWeek: scheduleViewModel.selectedWeek,
                    onSave: { course in
                        scheduleViewModel.addCourse(course)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
            case .createEvent:
                CreateANewEventView(
                    currentWeek: scheduleViewModel.selectedWeek,
                    currentDate: scheduleViewModel.defaultEventDate,
                    onSave: { event in
                        scheduleViewModel.addEvent(event)
                    },
                    onValidate: { event in
                        scheduleViewModel.validationMessage(for: event)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
            }
        }
    }

    private var blankScheduleContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                TimeAxis(times: MockData.times)
                    .frame(width: leftAxisW, height: scheduleAreaH)
                emptySlotGrid
            }
            .frame(width: 378, height: scheduleAreaH)

            HStack(spacing: 0) {
                Color.clear.frame(width: leftAxisW)
                BottomToggleBar(
                    mode: mode,
                    onToggle: {
                        scheduleViewModel.clearFlippedCourseCard()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            mode = mode == .courses ? .events : .courses
                        }
                    },
                    onAdd: { activeSheet = .createEvent }
                )
            }
            .frame(width: 378, height: 55)
            .padding(.top, 15)
        }
    }

    private var weekContentTransition: AnyTransition {
        switch weekSwipeDirection {
        case .next:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .previous:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }

    private var weekSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height),
                      abs(value.translation.width) > swipeThreshold else { return }
                if value.translation.width < 0 {
                    weekSwipeDirection = .next
                    scheduleViewModel.selectNextWeek()
                } else {
                    weekSwipeDirection = .previous
                    scheduleViewModel.selectPreviousWeek()
                }
            }
    }

    private var emptySlotGrid: some View {
        VStack(spacing: 15) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(spacing: 1) {
                    ForEach(0..<4, id: \.self) { _ in
                        HStack(spacing: colGap) {
                            ForEach(0..<7, id: \.self) { _ in
                                EmptySlotCard().frame(width: colW, height: 47)
                            }
                        }
                    }
                }
                .frame(width: gridW, height: blockH, alignment: .topLeading)
            }
        }
        .frame(width: gridW, height: scheduleAreaH, alignment: .topLeading)
    }
}

private enum BlankScheduleSheet: Identifiable {
    case createCourse
    case createEvent

    var id: String {
        switch self {
        case .createCourse: return "blank-course"
        case .createEvent: return "blank-event"
        }
    }
}
