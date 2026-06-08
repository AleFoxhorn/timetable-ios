import SwiftUI

struct CycleSelection: View {
    let number: Int
    let isSelected: Bool

    var body: some View {
        Text("\(number)")
            .font(.custom("MiSans-Regular", size: 18))
            .foregroundColor(isSelected ? AppColors.textOnDark : AppColors.textPrimary)
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
        CycleSelection(number: 9, isSelected: false)
        CycleSelection(number: 1, isSelected: true)
    }
    .padding(32)
    .background(Color.black)
}
