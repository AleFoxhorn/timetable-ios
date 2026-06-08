import SwiftUI

struct WarningPopoverOverlay<Content: View>: View {
    let onDismiss: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColors.modalScrim
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            content()
                .padding(.leading, 76)
                .padding(.top, 371)
        }
    }
}

struct InputReminderOverlay: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()

            InputReminderPopover(message: message)
                .padding(.bottom, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
}

struct QuitWarningPopover: View {
    let onCancel: () -> Void
    let onConfirmExit: () -> Void

    var body: some View {
        DualActionWarningPopover(
            message: "退出会丢失当前编辑的内容",
            leftTitle: "取消",
            rightTitle: "退出",
            onLeftTap: onCancel,
            onRightTap: onConfirmExit
        )
    }
}

struct DeleteWarningForSingleEventPopover: View {
    let onCancel: () -> Void
    let onConfirmDelete: () -> Void

    var body: some View {
        DualActionWarningPopover(
            message: "确认删除此事项？",
            leftTitle: "取消",
            rightTitle: "确认",
            onLeftTap: onCancel,
            onRightTap: onConfirmDelete
        )
    }
}

struct DeleteWarningForCoursePopover: View {
    let onDeleteThisWeek: () -> Void
    let onDeleteAll: () -> Void

    var body: some View {
        DualActionWarningPopover(
            message: "选择删除本周或全学周此课程",
            leftTitle: "本周",
            rightTitle: "全部",
            onLeftTap: onDeleteThisWeek,
            onRightTap: onDeleteAll
        )
    }
}

struct DeleteWarningForPluralEventsPopover: View {
    let onDeleteThisWeek: () -> Void
    let onDeleteAll: () -> Void

    var body: some View {
        DualActionWarningPopover(
            message: "选择删除本次或全部此事项",
            leftTitle: "本周",
            rightTitle: "全部",
            onLeftTap: onDeleteThisWeek,
            onRightTap: onDeleteAll
        )
    }
}

private struct DualActionWarningPopover: View {
    let message: String
    let leftTitle: String
    let rightTitle: String
    let onLeftTap: () -> Void
    let onRightTap: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.surfaceInverse)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.surfacePrimary, lineWidth: 2)
                )

            VStack(spacing: 0) {
                TextRow(message: message)
                    .padding(.bottom, -1)
                ButtonRow(
                    leftTitle: leftTitle,
                    rightTitle: rightTitle,
                    onLeftTap: onLeftTap,
                    onRightTap: onRightTap
                )
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .frame(width: 238, height: 105)
        .onTapGesture {}
    }
}

private struct InputReminderPopover: View {
    let message: String

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .fill(AppColors.surfaceInverse)

            Text(message)
                .font(.custom("MiSans-Regular", size: 16))
                .foregroundColor(AppColors.surfacePrimary)
                .padding(.leading, 16)
        }
        .frame(width: 159, height: 37)
    }
}

private struct TextRow: View {
    let message: String

    var body: some View {
        ZStack(alignment: .leading) {
            UnevenRoundedRectangle(
                topLeadingRadius: 5,
                bottomLeadingRadius: 15,
                bottomTrailingRadius: 15,
                topTrailingRadius: 5
            )
            .fill(AppColors.surfacePrimary)
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 5,
                    bottomLeadingRadius: 15,
                    bottomTrailingRadius: 15,
                    topTrailingRadius: 5
                )
                .stroke(AppColors.borderPrimary, lineWidth: 1)
            )

            Text(message)
                .font(.custom("MiSans-Regular", size: 15))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 205, alignment: .leading)
                .padding(.leading, 17)
        }
        .frame(width: 222, height: 46)
    }
}

private struct ButtonRow: View {
    let leftTitle: String
    let rightTitle: String
    let onLeftTap: () -> Void
    let onRightTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            warningButton(title: leftTitle, width: 112, corners: (15, 0, 5, 0), action: onLeftTap)
            warningButton(title: rightTitle, width: 111, corners: (0, 15, 0, 5), action: onRightTap)
        }
        .frame(width: 222, height: 40)
    }

    private func warningButton(
        title: String,
        width: CGFloat,
        corners: (CGFloat, CGFloat, CGFloat, CGFloat),
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom("MiSans-Regular", size: 15))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: width, height: 40)
        }
        .buttonStyle(.plain)
        .background(AppColors.surfacePrimary)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: corners.0,
                bottomLeadingRadius: corners.2,
                bottomTrailingRadius: corners.3,
                topTrailingRadius: corners.1
            )
        )
        .overlay(
            UnevenRoundedRectangle(
                topLeadingRadius: corners.0,
                bottomLeadingRadius: corners.2,
                bottomTrailingRadius: corners.3,
                topTrailingRadius: corners.1
            )
            .stroke(AppColors.borderPrimary, lineWidth: 1)
        )
    }
}
