import SwiftUI
import Charts

let genkiColors: [Color] = [
    Color(red: 0.45, green: 0.47, blue: 0.45), // 1
    Color(red: 0.20, green: 0.60, blue: 0.70), // 2
    Color(red: 0.56, green: 0.80, blue: 0.46), // 3
    Color(red: 1.00, green: 0.80, blue: 0.44), // 4
    Color(red: 1.00, green: 0.70, blue: 0.20)  // 5
]

// Identifiableな構造体
struct TagEmotionSelection: Identifiable, Equatable {
    let tag: String
    let emotion: String
    var id: String { "\(tag)_\(emotion)" }
}

struct ReportView: View {
    @Binding var selectedDate: Date?
    var ratingsForDates: [Date: Int]
    var items: [Item]
    @State private var reportType: ReportType = .monthly
    @State private var selectedDay: Int? = nil
    @State private var selectedTagEmotion: TagEmotionSelection? = nil

    enum ReportType: String, CaseIterable {
        case monthly = "月間"
        case yearly = "年間"
    }

    var body: some View {
        VStack(spacing: 24) {
            Picker("レポート種別", selection: $reportType) {
                ForEach(ReportType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Text(reportType == .monthly ? "月間レポート" : "年間レポート")
                .font(.title)
                .bold()

            // 月セレクター（省略、必要ならMonthSelectorを追加）
            if reportType == .monthly, let bindingDate = Binding($selectedDate) {
                MonthSelector(selectedDate: bindingDate)
                    .padding(.horizontal)
            }
            
            if reportType == .monthly {
                MonthlyLineChartView(
                    selectedDate: selectedDate,
                    ratingsForDates: ratingsForDates,
                    selectedDay: $selectedDay
                )
                .frame(height: 200)
                .padding(.horizontal)

                if let day = selectedDay, let value = monthlyRatings[safe: day-1] {
                    Text("\(day)日: \(value == 0 ? "データなし" : String(value))")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            } else {
                YearlyLineChartView(
                    selectedDate: selectedDate,
                    ratings: yearlyRatings,
                    onPointTap: { month in
                        // タップした月の処理
                    }
                )
                .frame(height: 180)
                .padding(.horizontal)

                if let idx = selectedDay {
                    Text("\(barLabel(at: idx - 1))")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            }

            DistributionBarView(
                reportType: reportType,
                selectedDate: selectedDate,
                ratingsForDates: ratingsForDates
            )
            .padding(.horizontal)

            TagEmotionAnalysisView(
                reportType: reportType,
                selectedDate: selectedDate,
                items: items,
                emotionDict: emotionDict,
                onDotTap: { tag, emotion in
                    selectedTagEmotion = TagEmotionSelection(tag: tag, emotion: emotion)
                }
            )
            .padding(.horizontal)

            Spacer()
        }
        .sheet(item: $selectedTagEmotion) { selection in
            let tag = selection.tag
            let emotion = selection.emotion
            let filtered = items.filter {
                ($0.emotionTags[emotion]?.contains(tag) ?? false)
            }
            VStack(spacing: 12) {
                Text("「\(tag)」×「\(emotion)」のメモ一覧")
                    .font(.headline)
                if filtered.isEmpty {
                    Text("該当するメモはありません")
                        .foregroundColor(.gray)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(filtered, id: \.id) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    if let note = item.emotionNotes[emotion], !note.isEmpty {
                                        // ★ ここを修正
                                        Text(note)
                                            .font(.body)
                                            .padding(8)
                                            .frame(maxWidth: .infinity, alignment: .leading) // ← 横幅固定
                                            .background(Color(.secondarySystemBackground))
                                            .cornerRadius(6)
                                    }
                                    Text(item.timestamp, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.bottom, 4)
                            }
                        }
                        .padding()
                    }
                }
                Button("閉じる") { selectedTagEmotion = nil }
                    .padding(.top, 12)
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
    }

    // --- 以下、補助プロパティ ---
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

    private func barLabel(at index: Int) -> String {
        let calendar = Calendar.current
        if reportType == .monthly, let selectedDate = selectedDate {
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
            let day = index + 1
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            return formatter.string(from: date)
        } else if reportType == .yearly, let selectedDate = selectedDate {
            let year = calendar.component(.year, from: selectedDate)
            let month = index + 1
            return "\(year)/\(month)"
        }
        return ""
    }
}

// タグごとの感情分析
struct TagEmotionAnalysisView: View {
    var reportType: ReportView.ReportType
    var selectedDate: Date?
    var items: [Item]
    var emotionDict: [String: Emotion]
    var onDotTap: (String, String) -> Void // (tag, emotion)

    var body: some View {
        let tagMap = tagEmotionMap()
        VStack(alignment: .leading, spacing: 8) {
            Text("タグごとの感情分布")
                .font(.headline)
            ForEach(tagMap.keys.sorted(), id: \.self) { tag in
                HStack {
                    Text(tag)
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)
                    ForEach(tagMap[tag] ?? [], id: \.id) { item in
                        ForEach(item.emotions, id: \.self) { emotionName in
                            if item.emotionTags[emotionName]?.contains(tag) == true {
                                Circle()
                                    .fill(emotionDict[emotionName]?.color ?? .gray)
                                    .frame(width: 16, height: 16)
                                    .onTapGesture { onDotTap(tag, emotionName) }
                                    .overlay(
                                        Circle().stroke(Color.white, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
            }
        }
    }

    // タグごとに該当Itemを抽出
    private func tagEmotionMap() -> [String: [Item]] {
        let filtered: [Item]
        let calendar = Calendar.current
        if reportType == .monthly, let selectedDate = selectedDate {
            let month = calendar.component(.month, from: selectedDate)
            let year = calendar.component(.year, from: selectedDate)
            filtered = items.filter {
                let comp = calendar.dateComponents([.year, .month], from: $0.timestamp)
                return comp.year == year && comp.month == month
            }
        } else if reportType == .yearly, let selectedDate = selectedDate {
            let year = calendar.component(.year, from: selectedDate)
            filtered = items.filter {
                let comp = calendar.dateComponents([.year], from: $0.timestamp)
                return comp.year == year
            }
        } else {
            filtered = []
        }
        var map: [String: [Item]] = [:]
        for item in filtered {
            for (_, tags) in item.emotionTags {
                for tag in tags {
                    map[tag, default: []].append(item)
                }
            }
        }
        // 重複Itemを除去
        for key in map.keys {
            map[key] = Array(Set(map[key]!))
        }
        return map
    }
}

// 配列の安全アクセス
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
