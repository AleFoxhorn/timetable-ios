import SwiftUI
import Observation

struct ScheduleScreen: View {
    private enum WeekSwipeDirection {
        case previous
        case next
    }

    private enum ActiveDeleteWarning: Identifiable {
        case singleEvent(ScheduleEvent)
        case pluralEvents(ScheduleEvent)
        case course(Course)

        var id: String {
            switch self {
            case .singleEvent(let event):
                return "single-event-\(event.id.uuidString)"
            case .pluralEvents(let event):
                return "plural-events-\(event.id.uuidString)"
            case .course(let course):
                return "course-\(course.id.uuidString)"
            }
        }
    }

    @Bindable var viewModel: ScheduleViewModel
    @Bindable var timetableViewModel: TimetableViewModel

    @State private var mode: DisplayMode = .courses
    @State private var activeSheet: ActiveSheet?
    @State private var detailsCourse: Course?
    @State private var detailsEvent: ScheduleEvent?
    @State private var activeDeleteWarning: ActiveDeleteWarning?
    @State private var weekSwipeDirection: WeekSwipeDirection = .next

    let onCreateSchedule: () -> Void

    private let colW: CGFloat = 45
    private let colGap: CGFloat = 1
    private let leftAxisW: CGFloat = 57
    private let gridW: CGFloat = 321
    private let scheduleAreaH: CGFloat = 603
    private let blockH: CGFloat = 191
    private let swipeThreshold: CGFloat = 40

    var body: some View {
        ZStack {
            AppColors.screenBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                TopHeader(
                    variant: .weeknumber,
                    title: viewModel.selectedWeekTitle,
                    onLeftAction: {
                        viewModel.clearFlippedCourseCard()
                        onCreateSchedule()
                    },
                    onRightAction: {
                        viewModel.clearFlippedCourseCard()
                        activeSheet = .createCourse(defaultWeek: viewModel.selectedWeek)
                    }
                )
                .frame(width: 393, height: 27)
                .frame(maxWidth: .infinity, alignment: .leading)

                WeekDateBar(month: viewModel.selectedWeekMonthLabel, days: viewModel.selectedWeekDayInfos)
                    .frame(width: 378, height: 40)
                    .padding(.top, 15)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    scheduleContent
                        .id(viewModel.selectedWeek)
                        .transition(weekContentTransition)
                }
                .frame(width: 378, height: scheduleAreaH + 70, alignment: .topLeading)
                .padding(.top, 15)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut(duration: 0.28), value: viewModel.selectedWeek)
                .gesture(weekSwipeGesture)

                Spacer(minLength: 17)
            }
            .padding(.top, 21)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let course = detailsCourse {
                overlayBackground {
                    detailsCourse = nil
                }

                CourseDetailsPopover(
                    course: course,
                    onEdit: {
                        detailsCourse = nil
                        activeSheet = .editCourse(course)
                    },
                    onReset: {
                        detailsCourse = nil
                        viewModel.clearFlippedCourseCard()
                        activeDeleteWarning = .course(course)
                    },
                    onDismiss: {
                        detailsCourse = nil
                    }
                )
            }

            if let event = detailsEvent {
                overlayBackground {
                    detailsEvent = nil
                }

                EventDetailsPopover(
                    event: event,
                    onEdit: {
                        detailsEvent = nil
                        activeSheet = .editEvent(event)
                    },
                    onReset: {
                        detailsEvent = nil
                        activeDeleteWarning = deleteWarning(for: event)
                    },
                    onDismiss: {
                        detailsEvent = nil
                    }
                )
            }

            if let activeDeleteWarning {
                deleteWarningOverlay(for: activeDeleteWarning)
            }

            TaskListOverlay(viewModel: viewModel)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .createCourse:
                CreateANewCourseView(
                    mode: .create,
                    currentWeek: viewModel.selectedWeek,
                    onSave: { course in
                        viewModel.addCourse(course)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)

            case .editCourse(let course):
                CreateANewCourseView(
                    mode: .edit,
                    currentWeek: viewModel.selectedWeek,
                    initialCourse: course,
                    onSave: { updatedCourse in
                        viewModel.updateCourse(updatedCourse)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)

            case .createEvent:
                CreateANewEventView(
                    currentWeek: viewModel.selectedWeek,
                    currentDate: viewModel.defaultEventDate,
                    onSave: { event in
                        viewModel.addEvent(event)
                    },
                    onValidate: { event in
                        viewModel.validationMessage(for: event)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)

            case .editEvent(let event):
                EditEventView(
                    event: event,
                    currentWeek: viewModel.selectedWeek,
                    currentDate: event.date,
                    onSave: { updatedEvent in
                        viewModel.updateEvent(updatedEvent)
                    },
                    onValidate: { updatedEvent in
                        viewModel.validationMessage(for: updatedEvent, excluding: event.id)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(0)
            }
        }
    }

    private func overlayBackground(onTap: @escaping () -> Void) -> some View {
        Color.black.opacity(0.35)
            .ignoresSafeArea()
            .onTapGesture(perform: onTap)
    }

    private func deleteWarning(for event: ScheduleEvent) -> ActiveDeleteWarning {
        event.repeatRule == .none ? .singleEvent(event) : .pluralEvents(event)
    }

    @ViewBuilder
    private func deleteWarningOverlay(for warning: ActiveDeleteWarning) -> some View {
        WarningPopoverOverlay(
            onDismiss: { activeDeleteWarning = nil }
        ) {
            switch warning {
            case .singleEvent(let event):
                DeleteWarningForSingleEventPopover(
                    onCancel: { activeDeleteWarning = nil },
                    onConfirmDelete: {
                        viewModel.deleteEvent(event)
                        activeDeleteWarning = nil
                    }
                )
            case .pluralEvents(let event):
                DeleteWarningForPluralEventsPopover(
                    onDeleteThisWeek: {
                        viewModel.deleteEventFromSelectedWeek(
                            id: event.id,
                            week: viewModel.selectedWeek
                        )
                        activeDeleteWarning = nil
                    },
                    onDeleteAll: {
                        viewModel.deleteEvent(event)
                        activeDeleteWarning = nil
                    }
                )
            case .course(let course):
                DeleteWarningForCoursePopover(
                    onDeleteThisWeek: {
                        viewModel.deleteCourseFromSelectedWeek(
                            courseID: course.id,
                            week: viewModel.selectedWeek
                        )
                        activeDeleteWarning = nil
                    },
                    onDeleteAll: {
                        viewModel.deleteCourse(course)
                        activeDeleteWarning = nil
                    }
                )
            }
        }
    }

    private var scheduleContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                TimeAxis(times: MockData.times)
                    .frame(width: leftAxisW, height: scheduleAreaH)

                ZStack(alignment: .topLeading) {
                    emptySlotGrid
                    courseLayer
                    eventLayer
                }
                .frame(width: gridW, height: scheduleAreaH, alignment: .topLeading)
            }
            .frame(width: 378, height: scheduleAreaH)

            HStack(spacing: 0) {
                Color.clear.frame(width: leftAxisW)
                BottomToggleBar(
                    mode: mode,
                    onToggle: {
                        viewModel.clearFlippedCourseCard()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            mode = (mode == .courses) ? .events : .courses
                        }
                    },
                    onAdd: {
                        viewModel.clearFlippedCourseCard()
                        activeSheet = .createEvent
                    }
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
                    viewModel.selectNextWeek()
                } else {
                    weekSwipeDirection = .previous
                    viewModel.selectPreviousWeek()
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

    @ViewBuilder
    private var courseLayer: some View {
        ForEach(viewModel.visibleCourseCards) { card in
            let pos = TimeMapper.slotToYAndHeight(
                startSlot: card.instance.startSlot,
                endSlot: card.instance.endSlot,
                config: MockData.defaultTimetableConfig
            )
            CourseCard(
                course: card.course,
                taskTexts: card.tasks.map(\.text),
                hasTasks: !card.tasks.isEmpty,
                isFlipped: viewModel.flippedCourseCardInstanceID == card.instance.id,
                onFlip: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        viewModel.flipCourseCard(card.instance.id)
                    }
                },
                onLongPress: {
                    viewModel.clearFlippedCourseCard()
                    detailsCourse = card.course
                },
                onLongPressBackFace: {
                    viewModel.openTaskPopover(for: card.instance.id)
                }
            )
            .frame(width: colW, height: pos.height)
            .offset(x: CGFloat(card.instance.weekday - 1) * (colW + colGap), y: pos.y)
            .allowsHitTesting(mode == .courses)
        }
    }

    @ViewBuilder
    private var eventLayer: some View {
        ForEach(viewModel.visibleEvents) { event in
            let startY = TimeMapper.timeToY(event.startTime, config: MockData.defaultTimetableConfig)
            let endY = TimeMapper.timeToY(event.endTime, config: MockData.defaultTimetableConfig)
            EventCard(
                startTime: event.startTime,
                endTime: event.endTime,
                content: event.title,
                mode: mode,
                onLongPress: {
                    viewModel.clearFlippedCourseCard()
                    detailsCourse = nil
                    detailsEvent = event
                }
            )
            .frame(width: colW, height: max(endY - startY, 0))
            .offset(x: CGFloat(event.weekday - 1) * (colW + colGap), y: startY)
        }
    }
}

private enum ActiveSheet: Identifiable {
    case createCourse(defaultWeek: Int)
    case editCourse(Course)
    case createEvent
    case editEvent(ScheduleEvent)

    var id: String {
        switch self {
        case .createCourse(let week):
            return "course-create-\(week)"
        case .editCourse(let course):
            return "course-edit-\(course.id.uuidString)"
        case .createEvent:
            return "event-create"
        case .editEvent(let event):
            return "event-edit-\(event.id.uuidString)"
        }
    }
}

#Preview {
    ScheduleScreen(
        viewModel: ScheduleViewModel(),
        timetableViewModel: TimetableViewModel(),
        onCreateSchedule: {}
    )
}
