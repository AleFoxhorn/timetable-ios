import SwiftUI

struct EditCourseBoardCell: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.surfacePrimary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.borderHeavy, lineWidth: 2)
                )

            RoundedRectangle(cornerRadius: 5)
                .fill(AppColors.surfaceInverse)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(AppColors.borderPrimary, lineWidth: 1)
                )
                .frame(width: 222, height: 265)
                .offset(x: 8, y: 10)
        }
        .frame(width: 238, height: 284)
        .shadow(color: .black.opacity(0.18), radius: 12, x: 0, y: 8)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        EditCourseBoardCell()
    }
}
