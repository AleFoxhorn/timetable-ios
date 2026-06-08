import SwiftUI

struct OriginnalDateCell: View {
    let date: Date

    private var dayText: String {
        "\(Calendar.current.component(.day, from: date))"
    }

    private var monthText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.standaloneMonthSymbols[Calendar.current.component(.month, from: date) - 1]
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(dayText)
                .font(AppFonts.semesterWeekDate)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
                .fixedSize()
                .frame(width: 24, height: 14, alignment: .center)
                .multilineTextAlignment(.center)

            Rectangle()
                .fill(AppColors.textPrimary)
                .frame(width: 24, height: 1.5)
                .clipShape(RoundedRectangle(cornerRadius: 2))
                .padding(.top, 4)

            Text(monthText)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(AppColors.textPrimary)
                .tracking(1)
                .lineLimit(1)
                .fixedSize()
                .frame(width: 24, height: 1.5, alignment: .center)
                .multilineTextAlignment(.center)
                .padding(.top, 7)
        }
        .frame(width: 24, height: 35, alignment: .top)
    }
}

struct SelectWeekRow: View {
    enum CornerStyle { case square, round }
    enum FillStyle { case white, grey }

    let dates: [Date]
    let fillStyle: FillStyle
    let cornerStyle: CornerStyle

    private var background: Color {
        switch fillStyle {
        case .white:
            return AppColors.semesterWeekRow
        case .grey:
            return AppColors.semesterWeekRowHighlight
        }
    }

    private var topRadius: CGFloat { cornerStyle == .square ? CardCornerRadius.microTop : CardCornerRadius.large }

    var body: some View {
        rowContent
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius:    topRadius,
                    bottomLeadingRadius: CardCornerRadius.large,
                    bottomTrailingRadius: CardCornerRadius.large,
                    topTrailingRadius:   topRadius
                )
            )
    }

    private var rowContent: some View {
        HStack(spacing: 0) {
            ForEach(Array(dates.prefix(7).enumerated()), id: \.offset) { idx, date in
                if idx > 0 { Spacer(minLength: 0) }
                dayCell(for: date)
            }
        }
        .padding(.horizontal, AppSpacing.semesterWeekRowHorizontalPadding)
        .frame(width: 325, height: 47)
        .background(background)
    }

    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        let day = Calendar.current.component(.day, from: date)
        if day == 1 {
            OriginnalDateCell(date: date)
        } else {
            Text("\(day)")
                .font(AppFonts.semesterWeekDate)
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 24, height: 35)
                .multilineTextAlignment(.center)
        }
    }
}

struct WeekHeaderRow: View {
    let weekdays: [String]

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            Color.clear.frame(width: 50, height: 11)

            HStack(spacing: AppSpacing.semesterWeekHeaderGap) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(AppFonts.semesterWeekHeader)
                        .foregroundColor(AppColors.textOnDark)
                        .frame(width: 41, alignment: .center)
                }
            }
            .frame(width: 325)
        }
        .frame(width: 393, height: 11, alignment: .leading)
    }
}

struct SelectWeekRowSection: View {
    let titleStyle: SelectWeekTitle.Style
    let dates: [Date]
    let fillStyle: SelectWeekRow.FillStyle
    let cornerStyle: SelectWeekRow.CornerStyle
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.semesterWeekRowGap) {
            SelectWeekTitle(style: titleStyle)
            SelectWeekRow(dates: dates, fillStyle: fillStyle, cornerStyle: cornerStyle)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    VStack(spacing: 4) {
        SelectWeekRowSection(
            titleStyle: .empty,
            dates: previewDates(startDay: 5),
            fillStyle: .white,
            cornerStyle: .square,
            onTap: {}
        )
        SelectWeekRowSection(
            titleStyle: .filled,
            dates: previewDates(startDay: 12),
            fillStyle: .grey,
            cornerStyle: .round,
            onTap: {}
        )
    }
    .padding(24)
    .background(Color.black)
}

private func previewDates(startDay: Int) -> [Date] {
    let calendar = Calendar.current
    return (0..<7).compactMap { offset in
        var comps = DateComponents()
        comps.year = 2026
        comps.month = 6
        comps.day = startDay + offset
        return calendar.date(from: comps)
    }
}
