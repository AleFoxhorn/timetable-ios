import SwiftUI

struct TimeAxisCell: View {
    let time: String
    let number: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(time)
                .font(.custom("MiSans-Regular", size: 10))
                .foregroundColor(AppColors.textOnDark)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("\(number)")
                .font(.custom("MiSans-Regular", size: 18))
                .foregroundColor(AppColors.textOnDark)
                .multilineTextAlignment(.center)
                .frame(height: 22)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    HStack(spacing: 8) {
        TimeAxisCell(time: "08:00", number: 1).frame(width: 57, height: 47)
        TimeAxisCell(time: "10:05", number: 3).frame(width: 57, height: 47)
        TimeAxisCell(time: "13:30", number: 5).frame(width: 57, height: 47)
        TimeAxisCell(time: "18:00", number: 9).frame(width: 57, height: 47)
    }
    .padding(24)
    .background(Color.black)
}
