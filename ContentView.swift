import SwiftUI
import SwiftData
import HorizonCalendar

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp) private var items: [Item]
    @State private var selectedTab = 0 // タブ管理用
    @State private var selectedDate: Date? = Date()
    //@State private var initialMonth: Date = Date()
    @State private var showEditor = false
    

    // 今月の1日を計算
    private static var firstDayOfThisMonth: Date {
        let today = Date()
        let components = Calendar.current.dateComponents([.year, .month], from: today)
        return Calendar.current.date(from: components)!
    }
    @State private var initialMonth: Date = firstDayOfThisMonth
    
    // 月間データ取得（追加）
    private var monthlyRatings: [Int] {
        let calendar = Calendar.current
        // selectedDateがnilの可能性がある場合はguardで安全に
        guard
            let selectedDate = selectedDate, // ← Date?型の場合
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)),
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return [] }

        return range.compactMap { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { return nil }
            // ratingがなければ0
            return ratingsForDates[calendar.startOfDay(for: date)] ?? 0
        }
    }

    var ratingsForDates: [Date: Int] {
        Dictionary(
            uniqueKeysWithValues: items.map { (Calendar.current.startOfDay(for: $0.timestamp), $0.rating) }
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // カレンダー画面（メイン）
            HomeCalendarView(
                selectedDate: $selectedDate,
                initialMonth: $initialMonth,
                selectedTab: $selectedTab,
                ratingsForDates: ratingsForDates,
                items: items
            )
            .tabItem { Label("Calendar", systemImage: "calendar") }
            .tag(0)

            // レポート画面
            ReportView(
                selectedDate: $selectedDate,
                ratingsForDates: ratingsForDates
            )
            .tabItem { Label("Report", systemImage: "chart.bar.fill") }
            .tag(1)

            // 目標画面
            Text("Goal Screen")
                .tabItem { Label("Goal", systemImage: "target") }
                .tag(2)
        }
    }
}


#Preview {
    ContentView()
}
