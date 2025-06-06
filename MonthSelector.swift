import SwiftUI

struct MonthSelector: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current
    private let years: [Int]
    private let months: [Int] = Array(1...12)

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        // 例: 直近10年分
        let currentYear = calendar.component(.year, from: Date())
        self.years = Array((currentYear-5)...(currentYear+2))
    }

    var body: some View {
        HStack {
            Picker("年", selection: yearBinding) {
                ForEach(years, id: \.self) { year in
                    Text("\(year)年").tag(year)
                }
            }
            .pickerStyle(.menu)

            Picker("月", selection: monthBinding) {
                ForEach(months, id: \.self) { month in
                    Text("\(month)月").tag(month)
                }
            }
            .pickerStyle(.menu)
        }
    }

    // Binding for year
    private var yearBinding: Binding<Int> {
        Binding<Int>(
            get: { calendar.component(.year, from: selectedDate) },
            set: { newYear in
                let month = calendar.component(.month, from: selectedDate)
                if let newDate = calendar.date(from: DateComponents(year: newYear, month: month, day: 1)) {
                    selectedDate = newDate
                }
            }
        )
    }
    // Binding for month
    private var monthBinding: Binding<Int> {
        Binding<Int>(
            get: { calendar.component(.month, from: selectedDate) },
            set: { newMonth in
                let year = calendar.component(.year, from: selectedDate)
                if let newDate = calendar.date(from: DateComponents(year: year, month: newMonth, day: 1)) {
                    selectedDate = newDate
                }
            }
        )
    }
}
