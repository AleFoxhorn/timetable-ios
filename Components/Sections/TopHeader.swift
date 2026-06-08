import SwiftUI

struct TopHeader: View {

    /// 对应 Figma Property 1 的五种变体名称
    enum Variant {
        /// 正常课表周次头：左=新建课表, 中=周次, 右=+
        case weeknumber
        /// 无课表提示头：左=新建课表, 中="点击左侧新建课表", 右=空占位
        case buildnewsheet
        /// 选择学期第一周：左=返回, 中="选择学期第一周", 右=空占位
        case choosethefirstweek
        /// 学期预览头：左=返回(白圆), 中="学期预览", 右=确认(白圆)
        case preview
        /// 新建/编辑课程头：左=取消(灰圆), 中=标题, 右=确认(白圆)
        case newschedule
    }

    let variant: Variant
    /// weeknumber / newschedule 使用此标题；buildnewsheet / preview 标题由 variant 固定
    var title: String = ""
    let onLeftAction: () -> Void
    let onRightAction: () -> Void

    private var displayTitle: String {
        switch variant {
        case .weeknumber:    return title
        case .buildnewsheet: return "点击左侧新建课表"
        case .choosethefirstweek: return "选择学期第一周"
        case .preview:       return "学期预览"
        case .newschedule:   return title
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            leftButton
            Text(displayTitle)
                .font(AppFonts.semesterHeaderTitle)
                .foregroundColor(AppColors.textOnDark)
                .kerning(-1.3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            rightButton
        }
        .padding(.horizontal, AppSpacing.topHeaderHorizontalPadding)
    }

    // MARK: - Left button

    @ViewBuilder
    private var leftButton: some View {
        switch variant {
        case .weeknumber, .buildnewsheet:
            CircleIconButton(style: .createCalendar, action: onLeftAction)
        case .choosethefirstweek, .preview:
            CircleIconButton(style: .goBack, action: onLeftAction)
        case .newschedule:
            CircleIconButton(style: .quit, action: onLeftAction)
        }
    }

    // MARK: - Right button

    @ViewBuilder
    private var rightButton: some View {
        switch variant {
        case .weeknumber:
            CircleIconButton(style: .createSchedule, action: onRightAction)
        case .preview, .newschedule:
            CircleIconButton(style: .confirm, action: onRightAction)
        case .buildnewsheet, .choosethefirstweek:
            Color.clear.frame(width: 27, height: 27)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // weeknumber
        TopHeader(variant: .weeknumber, title: "第十周",
                  onLeftAction: {}, onRightAction: {})

        // buildnewsheet
        TopHeader(variant: .buildnewsheet,
                  onLeftAction: {}, onRightAction: {})

        // choosethefirstweek
        TopHeader(variant: .choosethefirstweek,
                  onLeftAction: {}, onRightAction: {})

        // preview
        TopHeader(variant: .preview,
                  onLeftAction: {}, onRightAction: {})

        // newschedule
        TopHeader(variant: .newschedule, title: "新建课程",
                  onLeftAction: {}, onRightAction: {})
    }
    .padding(.vertical, 24)
    .background(Color.black)
}
