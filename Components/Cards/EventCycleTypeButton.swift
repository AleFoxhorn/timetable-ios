import SwiftUI

struct EventCycleTypeButton: View {
    let label: String
    let isSelected: Bool

    var body: some View {
        Text(label)
            .font(.custom("MiSans-Medium", size: 16))
            .foregroundColor(isSelected ? AppColors.textOnDark : AppColors.textActive)
            .frame(width: 83, height: 30)
            .background(isSelected ? AppColors.textPrimary : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.borderPrimary, lineWidth: isSelected ? 0 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    HStack(spacing: 8) {
        EventCycleTypeButton(label: "不重复", isSelected: true)
        EventCycleTypeButton(label: "每周", isSelected: false)
    }
    .padding(32)
    .background(Color.black)
}
