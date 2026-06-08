import SwiftUI

struct CourseDetailsPopover: View {
    let course: Course
    let onEdit: () -> Void
    let onReset: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            EditCourseBoardCell()

            VStack(spacing: -1) {
                EditCourseSelectCell(
                    text: course.name.isEmpty ? "未命名课程" : course.name,
                    variant: .title
                )
                EditCourseSelectCell(
                    text: locationText,
                    variant: .middle
                )
                EditCourseSelectCell(
                    text: weekText,
                    variant: .middle
                )
                EditCourseSelectCell(
                    text: course.displayTimeText,
                    variant: .bottom
                )
                EditCourseSelectCell(
                    text: course.teacher.isEmpty ? "授课教师" : course.teacher,
                    variant: .middle
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

    private var locationText: String {
        let combined = [course.location, course.classroom]
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .joined()
        return combined.isEmpty ? "未明确地点" : combined
    }

    private var weekText: String {
        let text = course.displayWeekText.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "第\(course.weeks.first ?? 1)周" : text
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CourseDetailsPopover(
            course: Course(
                name: "工程制图",
                classroom: "305",
                locationRaw: "第二教学馆 305",
                location: "第二教学馆",
                teacher: "授课教师",
                weekday: 4,
                startSlot: 1,
                endSlot: 4,
                weeks: Array(1...16),
                weekPattern: .odd
            ),
            onEdit: {},
            onReset: {},
            onDismiss: {}
        )
    }
}
