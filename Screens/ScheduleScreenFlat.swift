import SwiftUI

struct ScheduleScreenFlat: View {
    @State private var viewModel = ScheduleViewModel()
    @State private var timetableViewModel = TimetableViewModel()

    var body: some View {
        ScheduleScreen(
            viewModel: viewModel,
            timetableViewModel: timetableViewModel,
            onCreateSchedule: {}
        )
    }
}

#Preview {
    ScheduleScreenFlat()
}
