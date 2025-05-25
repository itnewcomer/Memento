import SwiftUI

struct RecordEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date?      // ← Date?型に変更
    var items: [Item]
    var onComplete: () -> Void

    @State private var rating: Int = 3
    @State private var selectedEmotions: Set<String> = []
    @State private var emotionNotes: [String: String] = [:]

    // 既存アイテムがあれば取得
    private var currentItem: Item? {
        guard let selectedDate = selectedDate else { return nil }
        return items.first { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate) }
    }

    // 感情名から色を取得（emotionGroupsベース）
    private func colorForEmotion(_ name: String) -> Color {
        for group in emotionGroups {
            if let emotion = group.emotions.first(where: { $0.name == name }) {
                return emotion.color
            }
        }
        return .gray
    }

    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    // ヘッダー
                    HStack {
                        if let selectedDate = selectedDate {
                            Text(selectedDate, style: .date)
                                .font(.headline)
                                .foregroundColor(.white)
                        } else {
                            Text("日付未選択")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button("キャンセル") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)

                    // 評価入力
                    StarRatingView(rating: $rating)

                    // 感情選択マトリクス（グループ版を使用）
                    EmotionMatrixView(
                        emotionRows: emotionRows,
                        emotionGroups: emotionGroups,
                        selectedEmotions: $selectedEmotions
                    )
                    .padding(.horizontal, 10)

                    // 選択された感情のメモ入力欄
                    ForEach(Array(selectedEmotions.sorted()), id: \.self) { emotion in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Circle()
                                    .fill(colorForEmotion(emotion))
                                    .frame(width: 24, height: 24)
                                Text(emotion)
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            TextEditor(text: Binding(
                                get: { emotionNotes[emotion] ?? "" },
                                set: { emotionNotes[emotion] = $0 }
                            ))
                            .frame(height: 100)
                            .padding(4)
                            .background(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(colorForEmotion(emotion), lineWidth: 2)
                            )
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                    }

                    // 保存ボタン
                    Button(currentItem != nil ? "更新" : "保存") {
                        saveData()
                        onComplete()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("ButtonGreen"))
                    .padding(.horizontal, 60)
                    .disabled(selectedDate == nil)
                }
                .padding(.vertical)
            }
        }
        .onAppear(perform: loadExistingData)
        .onChange(of: selectedEmotions) { oldValue, newValue in
            // 感情が追加された場合にメモ用のキーを作成
            let addedEmotions = newValue.subtracting(oldValue)
            for emotion in addedEmotions {
                emotionNotes[emotion] = ""
            }
            // 感情が削除された場合にメモを削除
            let removedEmotions = oldValue.subtracting(newValue)
            for emotion in removedEmotions {
                emotionNotes.removeValue(forKey: emotion)
            }
        }
    }

    private func loadExistingData() {
        if let item = currentItem {
            rating = item.rating
            selectedEmotions = Set(item.emotions)
            emotionNotes = item.emotionNotes
        }
    }

    private func saveData() {
        guard let selectedDate = selectedDate else { return }
        if let item = currentItem {
            // 既存アイテム更新
            item.rating = rating
            item.emotions = Array(selectedEmotions)
            item.emotionNotes = emotionNotes
        } else {
            // 新規アイテム作成
            let newItem = Item(
                timestamp: Calendar.current.startOfDay(for: selectedDate),
                rating: rating,
                memoText: "",
                emotions: Array(selectedEmotions),
                emotionNotes: emotionNotes
            )
            modelContext.insert(newItem)
        }
        try? modelContext.save()
    }
}
