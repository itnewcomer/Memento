import SwiftUI
import Charts

// グラフ（年間）
struct YearlyLineChartView: View {
    var selectedDate: Date?
    var ratings: [Int] // 12 months ratings
    var onPointTap: (Int) -> Void

    var body: some View {
        let data = ratings.enumerated().map { (index, value) in
            (month: index + 1, rating: value)
        }

        Chart(data, id: \.month) { item in
            LineMark(
                x: .value("Month", item.month),
                y: .value("Rating", item.rating)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color.accentColor)

            PointMark(
                x: .value("Month", item.month),
                y: .value("Rating", item.rating)
            )
            .foregroundStyle(item.rating > 0 && item.rating <= 5 ? genkiColors[item.rating - 1] : .gray)
            .symbolSize(100)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                AxisGridLine()
                AxisValueLabel() {
                    if let intValue = value.as(Int.self) {
                        Text("\(intValue)月")
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                if let month: Int = proxy.value(atX: x) {
                                    onPointTap(month)
                                }
                            }
                    )
            }
        }
        .frame(height: 200)
    }
}
