import SwiftUI
import HorizonCalendar

struct HorizonCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date?
    @Binding var initialMonth: Date
    let onMonthChanged: ((Date) -> Void)?   // ← 追加！
    let calendar: Calendar
    let visibleDateRange: ClosedRange<Date>
    let monthsLayout: MonthsLayout
    let ratingsForDates: [Date: Int]
    
    // カレンダーの現在表示月を記憶（初回のみジャンプ）
    class Coordinator {
        var didScrollToInitialMonth = false
    }
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> CalendarView {
        let calendarView = CalendarView(
            initialContent: makeContent(selectedDate: selectedDate)
        )
        calendarView.daySelectionHandler = { day in
            if let date = calendar.date(from: day.components) {
                DispatchQueue.main.async {
                    self.selectedDate = date
                }
            }
        }
        return calendarView
    }

    func updateUIView(_ uiView: CalendarView, context: Context) {
        uiView.setContent(makeContent(selectedDate: selectedDate))
        
        // 初回 or initialMonthが変わったときだけジャンプ
        let monthDate = calendar.date(from: calendar.dateComponents([.year, .month], from: initialMonth))!
        if !context.coordinator.didScrollToInitialMonth ||
            !calendar.isDate(
                uiView.visibleMonthRange
                    .flatMap { calendar.date(from: $0.lowerBound.components) } ?? Date(),
                equalTo: monthDate,
                toGranularity: .month
            ) {
            uiView.scroll(
                toMonthContaining: monthDate,
                scrollPosition: .centered,
                animated: false
            )
            context.coordinator.didScrollToInitialMonth = true
        }
        if let monthComponents = uiView.visibleMonthRange?.lowerBound.components,
           let monthDate = calendar.date(from: monthComponents) {
            onMonthChanged?(monthDate)
        }
    }
    private func makeContent(selectedDate: Date?) -> CalendarViewContent {
        // GnBuカラーパレット（ColorBrewer 5段階）
        let genkiColors: [Color] = [
            Color(red: 0.45, green: 0.47, blue: 0.45), // グレー明るい黄緑
            Color(red: 0.20, green: 0.60, blue: 0.70), // 明るめグリーン
            Color(red: 0.56, green: 0.80, blue: 0.46), // 中間グリーン
            Color(red: 1.00, green: 0.80, blue: 0.44), // 中間色（グリーン寄りのイエロー）
            Color(red: 1.00, green: 0.70, blue: 0.20)  //
        ]
        
        return CalendarViewContent(
            calendar: calendar,
            visibleDateRange: visibleDateRange,
            monthsLayout: monthsLayout
        )
        .dayItemProvider { day in
            guard let date = calendar.date(from: day.components) else {
                return Text("-").calendarItemModel
            }
            // rating取得（なければ0）
            let rating = ratingsForDates[calendar.startOfDay(for: date)] ?? 0
            
            let color: Color
            if (1...5).contains(rating) {
                color = genkiColors[rating - 1]
            } else {
                color = Color.clear // データなし
            }
            
            let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
            let isToday = calendar.isDateInToday(date)
            return Text("\(calendar.component(.day, from: date))")
                 .font(.system(size: 18, weight: isSelected ? .bold : .regular))
                 .foregroundColor(
                    isSelected ? .white : (isToday ? .white : .primary)
                 )
                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                 .background(
                     ZStack {
                         // 背景色（選択時も今日も関係なく常に塗る）
                         RoundedRectangle(cornerRadius: 8).fill(color)
                         // 赤枠（今日なら必ず表示）
                         if isToday {
                             RoundedRectangle(cornerRadius: 8)
                                 .stroke(Color.orange, lineWidth: 2)
                         }
                     }
                 )
                 .calendarItemModel
        }
    }
}
