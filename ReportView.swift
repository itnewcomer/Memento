import SwiftUI

struct ReportView: View {
    @Binding var selectedDate: Date?   // ← Date?で統一
    var ratingsForDates: [Date: Int]   // 日付ごとの評価データ
    @State private var reportType: ReportType = .monthly

    enum ReportType: String, CaseIterable {
        case monthly = "月間"
        case yearly = "年間"
    }

    var body: some View {
        VStack(spacing: 24) {
            // レポートタイプ選択
            Picker("レポート種別", selection: $reportType) {
                ForEach(ReportType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // タイトル
            Text(reportType == .monthly ? "月間レポート" : "年間レポート")
                .font(.title)
                .bold()

            // グラフ表示
            // LineChartView(data: reportType == .monthly ? monthlyRatings : yearlyRatings)
            //     .frame(height: 300)
            //     .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
        .background(Color(.systemBackground))
    }

    // 月間データ
    private var monthlyRatings: [Int] {
        let calendar = Calendar.current
        guard
            let selectedDate = selectedDate,
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)),
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return [] }

        return range.compactMap { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { return nil }
            return ratingsForDates[calendar.startOfDay(for: date)] ?? 0
        }
    }

    // 年間データ（月ごとの平均）
    private var yearlyRatings: [Int] {
        let calendar = Calendar.current
        guard let selectedDate = selectedDate else { return [] }
        let year = calendar.component(.year, from: selectedDate)

        return (1...12).map { month in
            let components = DateComponents(year: year, month: month)
            guard let startOfMonth = calendar.date(from: components) else { return 0 }

            let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)!
            let ratings = daysInMonth.compactMap { day -> Int? in
                guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { return nil }
                return ratingsForDates[calendar.startOfDay(for: date)]
            }

            guard !ratings.isEmpty else { return 0 }
            return ratings.reduce(0, +) / ratings.count
        }
    }
}

#Preview {
    ReportView(
        selectedDate: .constant(Date()), // ← Date?型で渡す
        ratingsForDates: [
            Calendar.current.startOfDay(for: Date()): 5,
            Calendar.current.startOfDay(for: Date().addingTimeInterval(-86400 * 30)): 3
        ]
    )
}
