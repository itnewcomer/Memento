import SwiftUI
import Charts

// 分布バー（1〜5の色割合）
struct DistributionBarView: View {
    var reportType: ReportView.ReportType
    var selectedDate: Date?
    var ratingsForDates: [Date: Int]

    let barHeight: CGFloat = 22

    var body: some View {
        GeometryReader { geo in
            let counts = ratingCounts()
            let total = counts.reduce(0, +)
            let ratios: [CGFloat] = total > 0
                ? counts.map { CGFloat($0) / CGFloat(total) }
                : Array(repeating: 0, count: 5)

            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    ForEach(0..<5) { idx in
                        Rectangle()
                            .fill(genkiColors[idx])
                            .frame(width: ratios[idx] * geo.size.width, height: barHeight)
                    }
                }
                HStack(spacing: 0) {
                    ForEach(0..<5) { idx in
                        let width = ratios[idx] * geo.size.width
                        if width > 0 {
                            Text(String(format: "%.0f%%", ratios[idx] * 100))
                                .font(.caption2)
                                .foregroundColor(.white)
                                .frame(width: width, height: barHeight, alignment: .center)
                                .shadow(radius: 1)
                        }
                    }
                }
            }
            .cornerRadius(5)
            .frame(height: barHeight)
            .padding(.vertical, 4)
        }
        .frame(height: barHeight)
    }

    // 1〜5の件数を集計
    private func ratingCounts() -> [Int] {
        let calendar = Calendar.current
        var counts = [0, 0, 0, 0, 0]
        if reportType == .monthly, let selectedDate = selectedDate {
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
            for day in range {
                let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
                let rating = ratingsForDates[calendar.startOfDay(for: date)] ?? 0
                if (1...5).contains(rating) { counts[rating-1] += 1 }
            }
        } else if reportType == .yearly, let selectedDate = selectedDate {
            let year = calendar.component(.year, from: selectedDate)
            for month in 1...12 {
                let components = DateComponents(year: year, month: month)
                if let startOfMonth = calendar.date(from: components),
                   let range = calendar.range(of: .day, in: .month, for: startOfMonth) {
                    for day in range {
                        let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
                        let rating = ratingsForDates[calendar.startOfDay(for: date)] ?? 0
                        if (1...5).contains(rating) { counts[rating-1] += 1 }
                    }
                }
            }
        }
        return counts
    }
}
