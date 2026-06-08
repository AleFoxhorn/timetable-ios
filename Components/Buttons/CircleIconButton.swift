import SwiftUI

struct CircleIconButton: View {

    enum Style {
        /// 白圆 + 返回箭头（用于返回/关闭弹层）
        case goBack
        /// 白圆 + 确认勾（用于提交/确认）
        case confirm
        /// 浅灰圆 + ✕（用于取消/退出编辑）
        case quit
        /// 自定义图标：新建课表（书+加号徽章）
        case createCalendar
        /// 自定义图标：新建课程（方块+加号）
        case createSchedule
    }

    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) { label }
    }

    @ViewBuilder
    private var label: some View {
        switch style {
        case .goBack:
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 27, height: 27)
                .background(AppColors.textOnDark)
                .clipShape(Circle())

        case .confirm:
            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 27, height: 27)
                .background(AppColors.textOnDark)
                .clipShape(Circle())

        case .quit:
            Image(systemName: "xmark")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppColors.textPrimary)
                .frame(width: 27, height: 27)
                .background(AppColors.buttonFillClose)
                .clipShape(Circle())

        case .createCalendar:
            Image("creatnewcalendarbutton")
                .resizable()
                .renderingMode(.original)
                .frame(width: 27, height: 33)

        case .createSchedule:
            Image("addnewschadulebutton")
                .resizable()
                .renderingMode(.original)
                .frame(width: 27, height: 27)
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        CircleIconButton(style: .goBack,          action: {})
        CircleIconButton(style: .confirm,         action: {})
        CircleIconButton(style: .quit,            action: {})
        CircleIconButton(style: .createCalendar,  action: {})
        CircleIconButton(style: .createSchedule,  action: {})
    }
    .padding(32)
    .background(Color.black)
}
