import Observation
import Foundation

@Observable class ScheduleViewModel {
    struct VisibleCourseCard: Identifiable {
        let id: UUID
        let course: Course
        let instance: CourseCardInstance
        let tasks: [CourseTask]
    }

    var courses: [Course] = []
    var courseCardInstances: [CourseCardInstance] = []
    var courseTasks: [CourseTask] = []
    var events: [ScheduleEvent] = []
    var flippedCourseCardInstanceID: UUID?
    var activeTaskPopoverCourseCardInstanceID: UUID?
    var editingTaskID: UUID?
    var editingTaskText = ""
    var draftTaskCourseCardInstanceID: UUID?
    var draftTaskText = ""

    // MARK: - 学期配置

    /// 本学期开始日期（可由设置页修改）
    var semesterStartDate: Date = {
        var comps = DateComponents()
        comps.year = 2025; comps.month = 2; comps.day = 24
        return Calendar.current.date(from: comps) ?? Date()
    }()

    /// 学期总周数
    var totalWeeks: Int = 20

    // MARK: - 周次状态

    /// 用户当前选中的周次。
    /// 0 表示未开学，1...20 表示学期内周次，21 表示学期已结束。
    var selectedWeek: Int = 1

    /// 根据系统日期计算的当前周状态。
    /// 0 表示未开学，超过 totalWeeks 时返回 totalWeeks + 1。
    var currentWeek: Int {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: semesterStartDate, to: Date()).day ?? 0
        guard days >= 0 else { return 0 }
        let week = days / 7 + 1
        return min(totalWeeks + 1, week)
    }

    /// 选中周是否为本周
    var isCurrentWeek: Bool { currentWeek == selectedWeek }

    var selectedWeekTitle: String {
        if selectedWeek < 1 {
            return "未开学"
        }
        if selectedWeek > totalWeeks {
            return "学期已结束"
        }
        return "第\(selectedWeek)周"
    }

    private let coursesStorageURL: URL
    private let courseCardInstancesStorageURL: URL
    private let courseTasksStorageURL: URL
    private let eventsStorageURL: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.coursesStorageURL = documents.appendingPathComponent("courses.json")
        self.courseCardInstancesStorageURL = documents.appendingPathComponent("course_card_instances.json")
        self.courseTasksStorageURL = documents.appendingPathComponent("course_tasks.json")
        self.eventsStorageURL = documents.appendingPathComponent("events.json")
        loadCourses()
        loadCourseCardInstances()
        loadCourseTasks()
        migrateCourseCardInstancesIfNeeded()
        loadEvents()
        selectedWeek = currentWeek
    }

    // MARK: - CRUD

    func addCourse(_ course: Course) {
        courses.append(course)
        do {
            courseCardInstances.append(contentsOf: generateInstances(for: course))
            try persistCourses()
            try persistCourseCardInstances()
        } catch {
            print("Failed to save courses.json: \(error)")
        }
    }

    func deleteCourse(_ course: Course) {
        removeCourseCascade(courseID: course.id)
        do {
            try persistCourses()
            try persistCourseCardInstances()
            try persistCourseTasks()
        } catch {
            print("Failed to save courses.json: \(error)")
        }
    }

    func updateCourse(_ course: Course) {
        guard let idx = courses.firstIndex(where: { $0.id == course.id }) else { return }
        let previousInstances = courseCardInstances.filter { $0.courseId == course.id }
        let previousInstanceIDs = Set(previousInstances.map(\.id))
        let preservedIDs = Dictionary(uniqueKeysWithValues: previousInstances.map { ($0.stableKey, $0.id) })

        courses[idx] = course
        do {
            let regenerated = generateInstances(for: course, preservedIDs: preservedIDs)
            let regeneratedIDs = Set(regenerated.map(\.id))
            let removedInstanceIDs = previousInstanceIDs.subtracting(regeneratedIDs)
            courseTasks.removeAll { removedInstanceIDs.contains($0.courseCardInstanceId) }
            courseCardInstances.removeAll { $0.courseId == course.id }
            courseCardInstances.append(contentsOf: regenerated)
            try persistCourses()
            try persistCourseCardInstances()
            try persistCourseTasks()
        } catch {
            print("Failed to save courses.json: \(error)")
        }
    }

    func deleteCourse(id: UUID) {
        removeCourseCascade(courseID: id)
        do {
            try persistCourses()
            try persistCourseCardInstances()
            try persistCourseTasks()
        } catch {
            print("Failed to save courses.json: \(error)")
        }
    }

    func addEvent(_ event: ScheduleEvent) {
        events.append(event)
        sortEvents()
        do {
            try persistEvents()
        } catch {
            print("Failed to save events.json: \(error)")
        }
    }

    func updateEvent(_ event: ScheduleEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index] = event
        sortEvents()
        do {
            try persistEvents()
        } catch {
            print("Failed to save events.json: \(error)")
        }
    }

    func deleteEvent(_ event: ScheduleEvent) {
        deleteEvent(id: event.id)
    }

    func deleteEvent(id: UUID) {
        events.removeAll { $0.id == id }
        do {
            try persistEvents()
        } catch {
            print("Failed to save events.json: \(error)")
        }
    }

    func clearAllCourses() throws {
        courses.removeAll()
        courseCardInstances.removeAll()
        courseTasks.removeAll()
        try persistCourses()
        try persistCourseCardInstances()
        try persistCourseTasks()
    }

    func clearAllEvents() throws {
        events.removeAll()
        try persistEvents()
    }

    func applyTimetableConfig(_ config: TimetableConfig) {
        semesterStartDate = config.semesterStartMonday
        selectedWeek = currentWeek
    }

    var visibleCourseCards: [VisibleCourseCard] {
        courseCardInstances
            .filter { $0.week == selectedWeek }
            .sorted { lhs, rhs in
                if lhs.weekday != rhs.weekday {
                    return lhs.weekday < rhs.weekday
                }
                if lhs.startSlot != rhs.startSlot {
                    return lhs.startSlot < rhs.startSlot
                }
                return lhs.endSlot < rhs.endSlot
            }
            .compactMap { instance in
                guard let course = course(for: instance.courseId) else { return nil }
                return VisibleCourseCard(
                    id: instance.id,
                    course: course,
                    instance: instance,
                    tasks: tasks(for: instance.id)
                )
            }
    }

    var visibleEvents: [ScheduleEvent] {
        events
            .filter { $0.weeks.contains(selectedWeek) }
            .sorted(by: eventSort)
    }

    var selectedWeekDates: [Date] {
        weekDates(for: selectedWeek)
    }

    var selectedWeekDayInfos: [DayInfo] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"

        return selectedWeekDates.map { date in
            DayInfo(
                weekday: formatter.string(from: date).uppercased(),
                day: Calendar.current.component(.day, from: date),
                isToday: Calendar.current.isDateInToday(date)
            )
        }
    }

    var selectedWeekMonthLabel: String {
        guard let first = selectedWeekDates.first else { return "" }
        let month = Calendar.current.component(.month, from: first)
        return "\(month)\n月"
    }

    func validationMessage(for event: ScheduleEvent, excluding eventID: UUID? = nil) -> String? {
        if event.trimmedTitle.isEmpty {
            return "请输入课程/事项名称"
        }

        guard event.startMinutes < event.endMinutes else {
            return "时间冲突"
        }

        if hasConflict(withCoursesFor: event) || hasConflict(withEventsFor: event, excluding: eventID) {
            return "时间冲突"
        }

        return nil
    }

    func weekDates(for week: Int) -> [Date] {
        let calendar = Calendar.current
        let semesterWeekday = calendar.component(.weekday, from: semesterStartDate)
        let mondayOffset = (semesterWeekday + 5) % 7
        let startOfSemesterWeek = calendar.date(
            byAdding: .day,
            value: -mondayOffset,
            to: calendar.startOfDay(for: semesterStartDate)
        ) ?? semesterStartDate
        let targetWeekStart = calendar.date(byAdding: .day, value: (week - 1) * 7, to: startOfSemesterWeek) ?? startOfSemesterWeek
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: targetWeekStart)
        }
    }

    func dateInSelectedWeek(matching weekday: Int) -> Date {
        let dates = selectedWeekDates
        let safeIndex = max(0, min(dates.count - 1, weekday - 1))
        return dates[safeIndex]
    }

    var defaultEventDate: Date {
        if selectedWeek == currentWeek {
            return Date()
        }
        return selectedWeekDates.first ?? Date()
    }

    var storagePathDescription: String {
        coursesStorageURL.path
    }

    var activeTaskPopoverCourseCardInstance: CourseCardInstance? {
        guard let activeTaskPopoverCourseCardInstanceID else { return nil }
        return courseCardInstances.first { $0.id == activeTaskPopoverCourseCardInstanceID }
    }

    var activeCourseTasks: [CourseTask] {
        guard let instanceID = activeTaskPopoverCourseCardInstanceID else { return [] }
        return tasks(for: instanceID)
    }

    func selectPreviousWeek() {
        clearFlippedCourseCard()
        selectedWeek = max(0, selectedWeek - 1)
    }

    func selectNextWeek() {
        clearFlippedCourseCard()
        selectedWeek = min(totalWeeks + 1, selectedWeek + 1)
    }

    func course(for id: UUID) -> Course? {
        courses.first { $0.id == id }
    }

    func tasks(for courseCardInstanceID: UUID) -> [CourseTask] {
        courseTasks
            .filter { $0.courseCardInstanceId == courseCardInstanceID }
            .sorted { lhs, rhs in
                if lhs.createdAt != rhs.createdAt {
                    return lhs.createdAt < rhs.createdAt
                }
                return lhs.updatedAt < rhs.updatedAt
            }
    }

    func hasTasks(for courseCardInstanceID: UUID) -> Bool {
        courseTasks.contains { $0.courseCardInstanceId == courseCardInstanceID }
    }

    func flipCourseCard(_ courseCardInstanceID: UUID) {
        flippedCourseCardInstanceID = flippedCourseCardInstanceID == courseCardInstanceID ? nil : courseCardInstanceID
    }

    func clearFlippedCourseCard() {
        flippedCourseCardInstanceID = nil
    }

    func openTaskPopover(for courseCardInstanceID: UUID) {
        clearFlippedCourseCard()
        activeTaskPopoverCourseCardInstanceID = courseCardInstanceID
        editingTaskID = nil
        editingTaskText = ""
        draftTaskCourseCardInstanceID = nil
        draftTaskText = ""
    }

    func dismissTaskPopover() {
        activeTaskPopoverCourseCardInstanceID = nil
        editingTaskID = nil
        editingTaskText = ""
        draftTaskCourseCardInstanceID = nil
        draftTaskText = ""
    }

    func commitActiveTaskEditorIfNeeded() {
        commitDraftTaskIfNeeded()
        if let editingTaskID {
            commitEditingTaskIfNeeded(editingTaskID)
        }
    }

    func beginDraftTask(for courseCardInstanceID: UUID) {
        draftTaskCourseCardInstanceID = courseCardInstanceID
        draftTaskText = ""
        editingTaskID = nil
        editingTaskText = ""
    }

    func updateDraftTaskText(_ text: String) {
        draftTaskText = text
    }

    func commitDraftTaskIfNeeded() {
        guard let draftTaskCourseCardInstanceID else { return }
        let trimmed = draftTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        defer {
            self.draftTaskCourseCardInstanceID = nil
            self.draftTaskText = ""
        }
        guard !trimmed.isEmpty else { return }

        courseTasks.append(
            CourseTask(
                courseCardInstanceId: draftTaskCourseCardInstanceID,
                text: trimmed
            )
        )
        do {
            try persistCourseTasks()
        } catch {
            print("Failed to save course_tasks.json: \(error)")
        }
    }

    func startEditingTask(_ taskID: UUID) {
        guard let task = courseTasks.first(where: { $0.id == taskID }) else { return }
        draftTaskCourseCardInstanceID = nil
        draftTaskText = ""
        editingTaskID = taskID
        editingTaskText = task.text
    }

    func updateEditingTaskText(_ text: String) {
        editingTaskText = text
    }

    func commitEditingTaskIfNeeded(_ taskID: UUID) {
        guard editingTaskID == taskID else { return }
        let trimmed = editingTaskText.trimmingCharacters(in: .whitespacesAndNewlines)
        defer {
            self.editingTaskID = nil
            self.editingTaskText = ""
        }
        guard let index = courseTasks.firstIndex(where: { $0.id == taskID }) else { return }
        if trimmed.isEmpty {
            courseTasks.remove(at: index)
        } else {
            courseTasks[index].text = trimmed
            courseTasks[index].updatedAt = Date()
        }
        do {
            try persistCourseTasks()
        } catch {
            print("Failed to save course_tasks.json: \(error)")
        }
    }

    func deleteTask(_ taskID: UUID) {
        editingTaskID = nil
        editingTaskText = ""
        courseTasks.removeAll { $0.id == taskID }
        do {
            try persistCourseTasks()
        } catch {
            print("Failed to save course_tasks.json: \(error)")
        }
    }

    private func loadCourses() {
        guard FileManager.default.fileExists(atPath: coursesStorageURL.path) else { return }
        do {
            let data = try Data(contentsOf: coursesStorageURL)
            courses = try JSONDecoder().decode([Course].self, from: data)
        } catch {
            print("Failed to load courses.json: \(error)")
        }
    }

    private func persistCourses() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(courses)
        try data.write(to: coursesStorageURL, options: [.atomic])
    }

    private func loadCourseCardInstances() {
        guard FileManager.default.fileExists(atPath: courseCardInstancesStorageURL.path) else { return }
        do {
            let data = try Data(contentsOf: courseCardInstancesStorageURL)
            courseCardInstances = try JSONDecoder().decode([CourseCardInstance].self, from: data)
        } catch {
            print("Failed to load course_card_instances.json: \(error)")
        }
    }

    private func persistCourseCardInstances() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(courseCardInstances)
        try data.write(to: courseCardInstancesStorageURL, options: [.atomic])
    }

    private func loadCourseTasks() {
        guard FileManager.default.fileExists(atPath: courseTasksStorageURL.path) else { return }
        do {
            let data = try Data(contentsOf: courseTasksStorageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            courseTasks = try decoder.decode([CourseTask].self, from: data)
        } catch {
            print("Failed to load course_tasks.json: \(error)")
        }
    }

    private func persistCourseTasks() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(courseTasks)
        try data.write(to: courseTasksStorageURL, options: [.atomic])
    }

    private func loadEvents() {
        guard FileManager.default.fileExists(atPath: eventsStorageURL.path) else { return }
        do {
            let data = try Data(contentsOf: eventsStorageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            events = try decoder.decode([ScheduleEvent].self, from: data)
            sortEvents()
        } catch {
            print("Failed to load events.json: \(error)")
        }
    }

    private func persistEvents() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(events)
        try data.write(to: eventsStorageURL, options: [.atomic])
    }

    private func sortEvents() {
        events.sort(by: eventSort)
    }

    private func eventSort(_ lhs: ScheduleEvent, _ rhs: ScheduleEvent) -> Bool {
        if lhs.weekday != rhs.weekday {
            return lhs.weekday < rhs.weekday
        }
        if lhs.startMinutes != rhs.startMinutes {
            return lhs.startMinutes < rhs.startMinutes
        }
        return lhs.endMinutes < rhs.endMinutes
    }

    private func hasConflict(withCoursesFor event: ScheduleEvent) -> Bool {
        courses.contains { course in
            let sharedWeeks = Set(course.weeks).intersection(event.weeks)
            guard !sharedWeeks.isEmpty, course.weekday == event.weekday else { return false }

            let courseStart = startMinutes(for: course.startSlot)
            let courseEnd = endMinutes(for: course.endSlot)
            return ScheduleEvent.overlaps(
                startMinutes: event.startMinutes,
                endMinutes: event.endMinutes,
                otherStartMinutes: courseStart,
                otherEndMinutes: courseEnd
            )
        }
    }

    private func hasConflict(withEventsFor event: ScheduleEvent, excluding eventID: UUID?) -> Bool {
        events.contains { existingEvent in
            guard existingEvent.id != eventID else { return false }
            let sharedWeeks = Set(existingEvent.weeks).intersection(event.weeks)
            guard !sharedWeeks.isEmpty, existingEvent.weekday == event.weekday else { return false }

            return ScheduleEvent.overlaps(
                startMinutes: event.startMinutes,
                endMinutes: event.endMinutes,
                otherStartMinutes: existingEvent.startMinutes,
                otherEndMinutes: existingEvent.endMinutes
            )
        }
    }

    private func startMinutes(for slot: Int) -> Int {
        guard let segment = MockData.defaultTimetableConfig.segments.first(where: {
            if case .slot(let value) = $0.kind {
                return value == slot
            }
            return false
        }) else {
            return 0
        }
        return TimeMapper.timeToMinutes(segment.startTime)
    }

    private func endMinutes(for slot: Int) -> Int {
        guard let segment = MockData.defaultTimetableConfig.segments.first(where: {
            if case .slot(let value) = $0.kind {
                return value == slot
            }
            return false
        }) else {
            return 0
        }
        return TimeMapper.timeToMinutes(segment.endTime)
    }

    private func migrateCourseCardInstancesIfNeeded() {
        guard !courses.isEmpty, courseCardInstances.isEmpty else { return }
        courseCardInstances = courses.flatMap { generateInstances(for: $0) }
        do {
            try persistCourseCardInstances()
        } catch {
            print("Failed to migrate course_card_instances.json: \(error)")
        }
    }

    private func generateInstances(
        for course: Course,
        preservedIDs: [CourseCardInstance.StableKey: UUID] = [:]
    ) -> [CourseCardInstance] {
        course.weeks.sorted().map { week in
            let instance = CourseCardInstance(
                id: preservedIDs[
                    CourseCardInstance(
                        courseId: course.id,
                        week: week,
                        weekday: course.weekday,
                        startSlot: course.startSlot,
                        endSlot: course.endSlot
                    ).stableKey
                ] ?? UUID(),
                courseId: course.id,
                week: week,
                weekday: course.weekday,
                startSlot: course.startSlot,
                endSlot: course.endSlot
            )
            return instance
        }
    }

    private func removeCourseCascade(courseID: UUID) {
        let instanceIDs = Set(courseCardInstances.filter { $0.courseId == courseID }.map(\.id))
        courseTasks.removeAll { instanceIDs.contains($0.courseCardInstanceId) }
        courseCardInstances.removeAll { $0.courseId == courseID }
        courses.removeAll { $0.id == courseID }
        if let flippedCourseCardInstanceID, instanceIDs.contains(flippedCourseCardInstanceID) {
            self.flippedCourseCardInstanceID = nil
        }
        if let activeTaskPopoverCourseCardInstanceID, instanceIDs.contains(activeTaskPopoverCourseCardInstanceID) {
            dismissTaskPopover()
        }
    }
}
