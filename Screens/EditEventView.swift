import SwiftUI

struct EditEventView: View {
    let event: ScheduleEvent
    let currentWeek: Int
    let currentDate: Date
    let onSave: (ScheduleEvent) -> Void
    let onValidate: (ScheduleEvent) -> String?

    var body: some View {
        EventEditorScreen(
            mode: .edit,
            currentWeek: currentWeek,
            currentDate: currentDate,
            initialEvent: event,
            onSave: onSave,
            onValidate: onValidate
        )
    }
}

#Preview {
    EditEventView(
        event: ScheduleEvent(
            title: "会议",
            location: "第二教学馆305",
            date: Date(),
            startTime: "08:00",
            endTime: "09:00",
            repeatRule: .none,
            weeks: [10],
            notes: "事项备注"
        ),
        currentWeek: 10,
        currentDate: Date(),
        onSave: { _ in },
        onValidate: { _ in nil }
    )
}
