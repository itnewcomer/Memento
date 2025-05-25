import SwiftUI
import HorizonCalendar

struct CalendarViewRepresentable: View {
    @Binding var selectedDate: Date?
    @Binding var initialMonth: Date
    let ratingsForDates: [Date: Int]
    let onMonthChanged: (Date) -> Void             // 月が変わったときに呼ばれるクロージャ（Bindingではなく関数型に変更！）
    private let calendar = Calendar.current
    private let startDate: Date
    private let endDate: Date

    init(
        selectedDate: Binding<Date?>,
        initialMonth: Binding<Date>,
        ratingsForDates: [Date: Int],
        onMonthChanged: @escaping (Date) -> Void   // クロージャ型に変更
    ){
        self._selectedDate = selectedDate
        self._initialMonth = initialMonth
        self.ratingsForDates = ratingsForDates
        self.onMonthChanged = onMonthChanged       // クロージャを保持
        let today = calendar.startOfDay(for: Date())
        self.startDate = calendar.date(byAdding: .year, value: -2, to: today)!
        self.endDate = calendar.date(byAdding: .year, value: 2, to: today)!
    }

    var body: some View {
        HorizonCalendarView(
                    selectedDate: $selectedDate,
                    initialMonth: $initialMonth,
                    onMonthChanged: onMonthChanged,
                    calendar: calendar,
                    visibleDateRange: startDate...endDate,
                    monthsLayout: .horizontal(options: HorizontalMonthsLayoutOptions()),
                    ratingsForDates: ratingsForDates
                )
                .frame(height: 360)
        // 選択処理を追加したい場合はカスタムProviderを使います（下記参照）
    }
}
