import SwiftUI

struct DateCell: View {
    let weekday: String
    let day: Int
    let isToday: Bool

    var body: some View {
        VStack(spacing: 1) {
            Text(weekday)
                .font(.custom("MiSans-Regular", size: 10))
                .foregroundColor(isToday ? AppColors.textPrimary : AppColors.textOnDark)
            Text("\(day)")
                .font(.custom("MiSans-Regular", size: 22))
                .foregroundColor(isToday ? AppColors.textPrimary : AppColors.textOnDark)
        }
        .padding(.top, 8)
        .padding(.bottom, 5)
        .frame(width: 45, height: 35)
        .background(isToday ? AppColors.textOnDark : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    HStack(spacing: 1) {
        DateCell(weekday: "SAT", day: 29, isToday: false)
        DateCell(weekday: "SUN", day: 30, isToday: false)
        DateCell(weekday: "MON", day: 1,  isToday: false)
        DateCell(weekday: "TUE", day: 2,  isToday: true)
        DateCell(weekday: "WED", day: 3,  isToday: false)
        DateCell(weekday: "THU", day: 4,  isToday: false)
        DateCell(weekday: "FRI", day: 5,  isToday: false)
    }
    .padding(32)
    .background(Color.black)
}
