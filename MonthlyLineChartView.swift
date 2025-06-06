import SwiftUI
import Charts

struct DayRating: Identifiable {
    let id = UUID()
    let day: Int
    let value: Int
}
// 折れ線グラフ（月間）
struct MonthlyLineChartView: View {
    let selectedDate: Date?
    let ratingsForDates: [Date: Int]
    @Binding var selectedDay: Int?

    var body: some View {
        let data = monthlyData
        Chart(data) { item in
            LineMark(
                x: .value("日", item.day),
                y: .value("評価", item.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.accentColor)
            PointMark(
                x: .value("日", item.day),
                y: .value("評価", item.value)
            )
            .foregroundStyle((item.value > 0 && item.value <= 5) ? genkiColors[item.value-1] : .gray)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let intValue = value.as(Int.self), intValue % 5 == 0 || intValue == 1 {
                        Text("\(intValue)")
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                if let day: Int = proxy.value(atX: x) {
                                    selectedDay = min(max(day, 1), data.count)
                                }
                            }
                            .onEnded { _ in }
                    )
            }
        }
    }

    private var monthlyData: [DayRating] {
        let calendar = Calendar.current
        guard
            let selectedDate = selectedDate,
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)),
            let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return [] }

        return range.map { day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let value = ratingsForDates[calendar.startOfDay(for: date)] ?? 0
            return DayRating(day: day, value: value)
        }
    }
}
