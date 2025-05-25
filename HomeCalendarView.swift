import SwiftUI
import SwiftData
import HorizonCalendar

struct HomeCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDate: Date?
    @Binding var initialMonth: Date
    @Binding var selectedTab: Int
    var ratingsForDates: [Date: Int]
    var items: [Item]
    
    @State private var showEditor = false
    @State private var showDeleteAlert = false
    @State private var selectedEmotion: String? = nil
    @State private var currentMonth: Date = Date()
    
    private var selectedItem: Item? {
        guard let selectedDate = selectedDate else { return nil }
        return items.first { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate) }
    }
    
    private func emotionColor(for name: String) -> Color {
        for group in emotionGroups {
            if let emotion = group.emotions.first(where: { $0.name == name }) {
                return emotion.color
            }
        }
        return .gray
    }
    
    private func ratingEmoji(for rating: Int) -> String {
        switch rating {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😑"
        case 4: return "😊"
        case 5: return "😆"
        default: return "？"
        }
    }
    
    private var groupMatrix: [[EmotionGroup]] {
        [
            [emotionGroups[0], emotionGroups[1]],
            [emotionGroups[2], emotionGroups[3]]
        ]
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 年・月ラベル
                Text(currentMonth, formatter: monthYearFormatter)
                    .font(.title2)
                    .bold()
                    .padding(.top, 8)
                
                // 今日ボタン
                HStack {
                    Spacer()
                    Button(action: {
                        selectedDate = Date()
                    }) {
                        Label("today", systemImage: "calendar")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    //.padding(.trailing, 20)
                }
                
                // カレンダー表示
                CalendarViewRepresentable(
                    selectedDate: $selectedDate, // ← ここもDate?型
                    initialMonth: $initialMonth,
                    ratingsForDates: ratingsForDates,
                    onMonthChanged: { newMonthDate in
                        currentMonth = newMonthDate // ← ここだけ更新
                    }
                )
                //.padding(.bottom , 30)
                
                
                // データ表示部（サブView化）
                CalendarDetailSection(
                    item: selectedItem,
                    selectedEmotion: $selectedEmotion,
                    groupMatrix: groupMatrix,
                    emotionColor: emotionColor,
                    ratingEmoji: ratingEmoji,
                    showEditor: $showEditor,
                    showDeleteAlert: $showDeleteAlert
                )
                //.padding(.top, 8)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                // .padding(.horizontal)
                .frame(minHeight: 240)
                .transition(.slide)
                
               // Spacer(minLength: 0)
            }
            .padding(.horizontal)
            // .padding(.bottom, 300)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 44)
            }
            .background(Color(.systemBackground))
            .ignoresSafeArea(.keyboard, edges: .bottom)
            // 編集シート
            .sheet(isPresented: $showEditor) {
                NavigationStack {
                    RecordEditorView(
                        selectedDate: $selectedDate,    // ← ここもDate?型
                        items: items,
                        onComplete: { showEditor = false }
                    )
                    .environment(\.modelContext, modelContext)
                }
            }
            // 削除アラート
            .alert("削除確認", isPresented: $showDeleteAlert) {
                Button("削除", role: .destructive) {
                    if let item = selectedItem {
                        modelContext.delete(item)
                        try? modelContext.save()
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("この日の記録を完全に削除しますか？")
            }
        }
    }
}
// MARK: - データあり・なしで切り替えるサブView

struct CalendarDetailSection: View {
    let item: Item?
    @Binding var selectedEmotion: String?
    let groupMatrix: [[EmotionGroup]]
    let emotionColor: (String) -> Color
    let ratingEmoji: (Int) -> String
    @Binding var showEditor: Bool
    @Binding var showDeleteAlert: Bool

    var body: some View {
        if let item = item {
            CalendarDetailView(
                item: item,
                selectedEmotion: $selectedEmotion,
                groupMatrix: groupMatrix,
                emotionColor: emotionColor,
                ratingEmoji: ratingEmoji,
                showEditor: $showEditor,
                showDeleteAlert: $showDeleteAlert
            )
        } else {
            CalendarEmptyView(
                showEditor: $showEditor,
                showDeleteAlert: $showDeleteAlert
            )
        }
    }
}

// MARK: - データあり用サブView

struct CalendarDetailView: View {
    let item: Item
    @Binding var selectedEmotion: String?
    let groupMatrix: [[EmotionGroup]]
    let emotionColor: (String) -> Color
    let ratingEmoji: (Int) -> String
    @Binding var showEditor: Bool
    @Binding var showDeleteAlert: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(ratingEmoji(item.rating))
                    .font(.system(size: 48))
                    .frame(width: 60)
                Spacer()
                HStack(spacing: 20) {
                    Button(action: { showEditor = true }) {
                        Image(systemName: "pencil").font(.title2)
                    }
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }
            VStack(spacing: 12) {
                ForEach(0..<groupMatrix.count, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(0..<groupMatrix[row].count, id: \.self) { col in
                            let group = groupMatrix[row][col]
                            EmotionGridView(
                                group: group,
                                item: item,
                                selectedEmotion: $selectedEmotion
                            )
                        }
                    }
                }
                .padding(.top, 4)
            }
            if let emotion = selectedEmotion,
               let note = item.emotionNotes[emotion],
               !note.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(emotionColor(emotion))
                            .frame(width: 20, height: 20)
                        Text(emotion)
                            .font(.headline)
                            .foregroundColor(emotionColor(emotion))
                    }
                    Text(note)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 2)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                .padding(.leading, 0)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - データなし用サブView

struct CalendarEmptyView: View {
    @Binding var showEditor: Bool
    @Binding var showDeleteAlert: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer().frame(width: 60)
                Text("データなし")
                    .foregroundColor(.gray)
                    .font(.headline)
                Spacer()
                HStack(spacing: 20) {
                    Button(action: { showEditor = true }) {
                        Image(systemName: "pencil")
                            .font(.title2)
                    }
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }
            Spacer().frame(height: 248)
        }
    }
}

private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.dateFormat = "yyyy年 M月"
    return formatter
}
