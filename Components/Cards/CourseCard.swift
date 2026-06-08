import SwiftUI

private extension String {
    func wrappedText(charsPerLine: Int, maxLines: Int) -> String {
        guard !isEmpty, charsPerLine > 0, maxLines > 0 else { return "" }

        let characters = Array(self)
        let maxCount = min(characters.count, charsPerLine * maxLines)
        var lines: [String] = []
        var current = ""

        for index in 0..<maxCount {
            current.append(characters[index])
            if current.count == charsPerLine || index == maxCount - 1 {
                lines.append(current)
                current = ""
            }
        }

        return lines.joined(separator: "\n")
    }
}

struct CourseCard: View {
    let course: Course
    let taskTexts: [String]
    let hasTasks: Bool
    let isFlipped: Bool
    let onFlip: () -> Void
    let onLongPress: () -> Void
    let onLongPressBackFace: () -> Void

    @State private var suppressNextTap = false
    @GestureState private var isPressed = false

    private var slotSpan: Int {
        max(course.endSlot - course.startSlot + 1, 1)
    }

    private var titleText: String {
        let raw = course.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return (raw.isEmpty ? "未命名课程" : raw).wrappedText(charsPerLine: 3, maxLines: 2)
    }

    private var locationText: String {
        course.location.trimmingCharacters(in: .whitespacesAndNewlines).wrappedText(charsPerLine: 3, maxLines: 2)
    }

    private var classroomText: String {
        course.classroom.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var visibleBackTasks: [String] {
        let cleaned = taskTexts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !cleaned.isEmpty else { return ["暂无"] }

        let maxLines = max(slotSpan, 2)
        let visible = cleaned.prefix(max(0, maxLines - (cleaned.count > maxLines ? 1 : 0))).map { task in
            let raw = task.trimmingCharacters(in: .whitespacesAndNewlines)
            return (raw.isEmpty ? "暂无" : raw).wrappedText(charsPerLine: 3, maxLines: 1)
        }

        if cleaned.count > maxLines {
            return visible + ["..."]
        }

        return visible
    }

    private var frontFace: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(titleText)
                    .font(.custom("MiSans-Medium", size: 12))
                    .foregroundColor(AppColors.textPrimary)
                    .lineSpacing(0)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .frame(
                        minWidth: 0,
                        idealWidth: nil,
                        maxWidth: .infinity,
                        minHeight: 26,
                        idealHeight: nil,
                        maxHeight: nil,
                        alignment: .topLeading
                    )

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 6) {
                    if !locationText.isEmpty {
                        Text(locationText)
                            .font(.custom("MiSans-Regular", size: 10))
                            .foregroundColor(AppColors.textPrimary)
                            .lineSpacing(0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if !classroomText.isEmpty {
                        Text(classroomText)
                            .font(.custom("MiSans-Regular", size: 10))
                            .foregroundColor(AppColors.textPrimary)
                            .lineSpacing(0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.leading, 4)
            .padding(.top, 6)
            .padding(.trailing, 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Color.clear.frame(height: 11)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.courseCardFront)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(alignment: .bottomTrailing) {
            if hasTasks {
                Circle()
                    .stroke(AppColors.taskIndicator, lineWidth: 1.5)
                    .frame(width: 8, height: 8)
                    .padding(.trailing, 3)
                    .padding(.bottom, 3)
            }
        }
    }

    private var backFace: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(visibleBackTasks.enumerated()), id: \.offset) { index, task in
                    Group {
                        if index == 0 {
                            Text(task)
                                .font(.custom("MiSans-Medium", size: 12))
                                .foregroundColor(AppColors.textOnDark)
                                .lineSpacing(0)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .frame(
                                    minWidth: 0,
                                    idealWidth: nil,
                                    maxWidth: .infinity,
                                    minHeight: 22,
                                    idealHeight: nil,
                                    maxHeight: nil,
                                    alignment: .topLeading
                                )
                        } else {
                            Text(task)
                                .font(.custom("MiSans-Medium", size: 12))
                                .foregroundColor(AppColors.textOnDark)
                                .lineSpacing(0)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                    }
                }
            }
            .padding(.leading, 4)
            .padding(.top, 6)
            .padding(.trailing, 1)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Color.clear.frame(height: 11)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.courseCardBack)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppColors.surfacePrimary, lineWidth: 1)
        )
        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }

    var body: some View {
        ZStack {
            backFace.opacity(isFlipped ? 1 : 0)
            frontFace.opacity(isFlipped ? 0 : 1)
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.4
        )
        .animation(.easeInOut(duration: 0.4), value: isFlipped)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.16), value: isPressed)
        .onTapGesture {
            if suppressNextTap {
                suppressNextTap = false
                return
            }
            onFlip()
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($isPressed) { _, state, _ in
                    state = true
                }
                .onEnded { _ in
                    suppressNextTap = true
                    if isFlipped {
                        onLongPressBackFace()
                    } else {
                        onLongPress()
                    }
                }
        )
    }
}

#Preview {
    struct Wrapper: View {
        let width: CGFloat = 45
        @State private var flippedID: Int? = nil

        var body: some View {
            HStack(alignment: .top, spacing: 14) {
                ForEach([2, 3, 4], id: \.self) { slots in
                    let height = 47 * CGFloat(slots) + CGFloat(slots - 1)
                    CourseCard(
                        course: Course(
                            name: "思想政治",
                            classroom: "3-315",
                            locationRaw: "第二教学楼 3-315",
                            location: "第二教学楼",
                            teacher: "陈老师",
                            weekday: 1,
                            startSlot: 1,
                            endSlot: slots
                        ),
                        taskTexts: ["建模初稿提交", "改方案", "草图提交"],
                        hasTasks: true,
                        isFlipped: flippedID == slots,
                        onFlip: { flippedID = flippedID == slots ? nil : slots },
                        onLongPress: {},
                        onLongPressBackFace: {}
                    )
                    .frame(width: width, height: height)
                }
            }
            .padding(24)
            .background(Color.black)
        }
    }

    return Wrapper()
}
