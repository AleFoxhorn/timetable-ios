import SwiftUI

struct EditCourseSelectButtonCell: View {
    let onReset: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            button(title: "重置", width: 112, corners: (15, 0, 5, 0), action: onReset)
            button(title: "编辑", width: 111, corners: (0, 15, 0, 5), action: onEdit)
        }
        .frame(width: 222, height: 40)
    }

    private func button(
        title: String,
        width: CGFloat,
        corners: (CGFloat, CGFloat, CGFloat, CGFloat),
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom("MiSans-Regular", size: 15))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: width)
                .frame(maxHeight: .infinity)
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

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EditCourseSelectButtonCell(onReset: {}, onEdit: {})
    }
}
