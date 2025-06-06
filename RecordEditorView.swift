import SwiftUI

struct RecordEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date?
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

    // タグ抽出関数
    private func extractTags(from text: String) -> [String] {
        let pattern = "#[\\p{L}0-9_]+"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(text.startIndex..., in: text)
        let matches = regex?.matches(in: text, options: [], range: nsrange) ?? []
        return matches.compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
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

                    // 選択された感情のメモ入力欄＋タグ表示＋案内文
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
                            // ★案内文をTextEditorの「上」に分岐表示
                            if (emotionNotes[emotion] ?? "").isEmpty {
                                Text("#家族 #仕事 のようにタグも一緒に登録して集計できます")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .padding(.leading, 8)
                                    .padding(.bottom, 2)
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
                            // タグ表示
                            let tags = extractTags(from: emotionNotes[emotion] ?? "")
                            if !tags.isEmpty {
                                HStack {
                                    Text("タグ:")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    ForEach(tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(4)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(6)
                                    }
                                }
                                .padding(.top, 2)
                            }
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
                // 既存データがあればそれを使い、なければ空文字
                if let existing = currentItem?.emotionNotes[emotion] {
                    emotionNotes[emotion] = existing
                } else {
                    emotionNotes[emotion] = ""
                }
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
            emotionNotes = item.emotionNotes   // ここで各感情のメモをセット
        } else {
            rating = 3
            selectedEmotions = []
            emotionNotes = [:]
        }
    }

    private func saveData() {
        guard let selectedDate = selectedDate else { return }

        // 感情ごとのタグを抽出
        var newEmotionTags: [String: [String]] = [:]
        for (emotion, note) in emotionNotes {
            let tags = extractTags(from: note)
            newEmotionTags[emotion] = tags
        }

        if let item = currentItem {
            // 既存アイテム更新
            item.rating = rating
            item.emotions = Array(selectedEmotions)
            item.emotionNotes = emotionNotes
            item.emotionTags = newEmotionTags
            // 全体tagsも必要なら集約
            item.tags = Array(Set(newEmotionTags.values.flatMap { $0 }))
        } else {
            // 新規アイテム作成
            let emotionTags = newEmotionTags
            let tags = Array(Set(emotionTags.values.flatMap { $0 }))
            let newItem = Item(
                timestamp: Calendar.current.startOfDay(for: selectedDate),
                rating: rating,
                memoText: "",
                emotions: Array(selectedEmotions),
                emotionNotes: emotionNotes,
                tags: tags,
                emotionTags: emotionTags
            )
            modelContext.insert(newItem)
        }
        try? modelContext.save()
    }
}
