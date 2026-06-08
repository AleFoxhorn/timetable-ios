import SwiftUI

struct EditCourseSelectCell: View {
    enum Variant {
        case title
        case middle
        case bottom
    }

    let text: String
    let variant: Variant

    var body: some View {
        Text(text)
            .font(.custom("MiSans-Regular", size: 15))
            .foregroundColor(AppColors.textPrimary)
            .lineLimit(2)
            .frame(
                minWidth: 0,
                idealWidth: nil,
                maxWidth: .infinity,
                minHeight: 46,
                idealHeight: nil,
                maxHeight: nil,
                alignment: .leading
            )
            .padding(.horizontal, 17)
            .background(AppColors.surfacePrimary)
            .frame(width: 222, height: 46, alignment: .leading)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: topLeadingRadius,
                    bottomLeadingRadius: bottomLeadingRadius,
                    bottomTrailingRadius: bottomTrailingRadius,
                    topTrailingRadius: topTrailingRadius
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: topLeadingRadius,
                    bottomLeadingRadius: bottomLeadingRadius,
                    bottomTrailingRadius: bottomTrailingRadius,
                    topTrailingRadius: topTrailingRadius
                )
                .stroke(AppColors.borderPrimary, lineWidth: 1)
            )
    }

    private var topLeadingRadius: CGFloat {
        switch variant {
        case .title: return 5
        case .middle: return 15
        case .bottom: return 0
        }
    }

    private var topTrailingRadius: CGFloat {
        switch variant {
        case .title: return 5
        case .middle: return 15
        case .bottom: return 0
        }
    }

    private var bottomLeadingRadius: CGFloat {
        switch variant {
        case .title: return 15
        case .middle: return 0
        case .bottom: return 15
        }
    }

    private var bottomTrailingRadius: CGFloat {
        switch variant {
        case .title: return 15
        case .middle: return 0
        case .bottom: return 15
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        EditCourseSelectCell(text: "工程制图", variant: .title)
        EditCourseSelectCell(text: "第二教学馆305", variant: .middle)
        EditCourseSelectCell(text: "周四 | 1-4节", variant: .bottom)
    }
    .padding()
    .background(Color.black)
}
