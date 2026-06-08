import SwiftUI

struct EventDetailsPopover: View {
    let event: ScheduleEvent
    let onEdit: () -> Void
    let onReset: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            EditCourseBoardCell()

            VStack(spacing: -1) {
                EditCourseSelectCell(
                    text: event.trimmedTitle.isEmpty ? "未命名事项" : event.trimmedTitle,
                    variant: .title
                )
                EditCourseSelectCell(
                    text: event.trimmedLocation.isEmpty ? "未填写" : event.trimmedLocation,
                    variant: .middle
                )
                EditCourseSelectCell(
                    text: event.displayDateText,
                    variant: .middle
                )
                EditCourseSelectCell(
                    text: event.displayTimeText.replacingOccurrences(of: ":", with: "："),
                    variant: .middle
                )
                EditCourseSelectCell(
                    text: event.trimmedNotes.isEmpty ? "未填写" : "事项备注：\(event.trimmedNotes)",
                    variant: .bottom
                )
                EditCourseSelectButtonCell(
                    onReset: onReset,
                    onEdit: onEdit
                )
            }
            .frame(width: 222, height: 265, alignment: .top)
            .offset(x: 8, y: 9)
        }
        .frame(width: 238, height: 284)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EventDetailsPopover(
            event: ScheduleEvent(
                title: "会议",
                location: "第二教学馆305",
                date: Date(),
                startTime: "08:00",
                endTime: "09:00",
                repeatRule: .none,
                weeks: [10],
                notes: "带上汇报材料"
            ),
            onEdit: {},
            onReset: {},
            onDismiss: {}
        )
    }
}
