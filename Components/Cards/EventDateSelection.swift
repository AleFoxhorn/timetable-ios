import SwiftUI

struct EventDateSelection: View {
    let weekday: String
    let day: Int
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(weekday)
                .font(.custom("MiSans-Regular", size: 8))
                .foregroundColor(isSelected ? AppColors.textOnDark : AppColors.textPrimary)
            Text("\(day)")
                .font(.custom("MiSans-Regular", size: 18))
                .foregroundColor(isSelected ? AppColors.textOnDark : AppColors.textStrong)
                .padding(.top, 2)
        }
        .frame(width: 47, height: 39)
        .background(isSelected ? AppColors.textPrimary : AppColors.dateButtonUnselected)
        .overlay(
            RoundedRectangle(cornerRadius: 4.65)
                .stroke(
                    isSelected ? AppColors.borderPrimary : AppColors.textActive,
                    lineWidth: 1
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 4.65))
    }
}

#Preview {
    HStack(spacing: 8) {
        EventDateSelection(weekday: "WED", day: 25, isSelected: false)
        EventDateSelection(weekday: "WED", day: 25, isSelected: true)
    }
    .padding(32)
    .background(Color.black)
}
