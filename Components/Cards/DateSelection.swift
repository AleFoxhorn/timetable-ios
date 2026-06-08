import SwiftUI

struct DateSelection: View {
    let weekday: String
    let isSelected: Bool

    var body: some View {
        Text(weekday)
            .font(.custom("MiSans-Regular", size: 14))
            .foregroundColor(isSelected ? AppColors.textOnDark : AppColors.textStrong)
            .frame(width: 47, height: 39)
            .background(isSelected ? AppColors.textPrimary : AppColors.dateButtonUnselected)
            .overlay(
                RoundedRectangle(cornerRadius: 4.65)
                    .stroke(AppColors.borderPrimary, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 4.65))
    }
}

#Preview {
    HStack(spacing: 8) {
        DateSelection(weekday: "MON", isSelected: false)
        DateSelection(weekday: "WED", isSelected: true)
    }
    .padding(32)
    .background(Color.black)
}
