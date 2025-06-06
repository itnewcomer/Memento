import SwiftUI
import HorizonCalendar

struct CalendarViewRepresentable: View {
    @Binding var selectedDate: Date?
    @Binding var initialMonth: Date
    let ratingsForDates: [Date: Int]
    private let calendar = Calendar.current
    private let startDate: Date
    private let endDate: Date

    init(
        selectedDate: Binding<Date?>,
        initialMonth: Binding<Date>,
        ratingsForDates: [Date: Int],
    ){
        self._selectedDate = selectedDate
        self._initialMonth = initialMonth
        self.ratingsForDates = ratingsForDates
        let today = calendar.startOfDay(for: Date())
        self.startDate = calendar.date(byAdding: .year, value: -2, to: today)!
        self.endDate = calendar.date(byAdding: .year, value: 2, to: today)!
    }

    var body: some View {
        HorizonCalendarView(
                    selectedDate: $selectedDate,
                    initialMonth: $initialMonth,
                    calendar: calendar,
                    visibleDateRange: startDate...endDate,
                    monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()),
                    ratingsForDates: ratingsForDates
                )
                .frame(height: 360)
    }
}
