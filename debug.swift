//
//  debug.swift
//  Memento
//
//  Created by 小池慶彦 on 2025/05/21.
//
import SwiftUI


/*
 
 
 import SwiftUI
 import SwiftData
 import MijickCalendarView
 // emotionGroups, Emotion, EmotionGroupは共通ファイルで定義されている前提

 struct CalendarView: View {
     @Environment(\.modelContext) private var modelContext
     @Binding var selectedDate: Date?
     @Binding var selectedTab: Int
     var ratingsForDates: [Date: Int]
     var items: [Item]

     @State private var showEditor = false
     @State private var showDeleteAlert = false
     @State private var selectedEmotion: String? = nil // 選択中の感情
     @State private var selectedRange: MDateRange? = nil
     
     private var selectedItem: Item? {
         guard let selectedDate = selectedDate else { return nil }
         return items.first { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate) }
     }
     
     // 感情名から色を取得
     private func emotionColor(for name: String) -> Color {
         for group in emotionGroups {
             if let emotion = group.emotions.first(where: { $0.name == name }) {
                 return emotion.color
             }
         }
         return .gray
     }

     // 星評価を絵文字で表現
     private func ratingEmoji(for rating: Int) -> String {
         switch rating {
         case 1: return "😞"
         case 2: return "😐"
         case 3: return "😊"
         case 4: return "😄"
         case 5: return "🌟"
         default: return "？"
         }
     }
     
     // 2×2マトリクスでグループを並べる
     private var groupMatrix: [[EmotionGroup]] {
         [
             [emotionGroups[0], emotionGroups[1]], // 上段: 左・右
             [emotionGroups[2], emotionGroups[3]]  // 下段: 左・右
         ]
     }

     var body: some View {
         VStack(spacing: 16) {
             // 今日ボタン
             HStack {
                 Spacer()
                 Button(action: {
                     selectedDate = Date()
                 }) {
                     Label("今日", systemImage: "calendar")
                         .font(.caption)
                 }
                 .buttonStyle(.bordered)
                 .padding(.trailing, 20)
                 .padding(.top, 8)
             }
             
             // カレンダー表示
           // CalendarViewRepresentable(selectedDate: $selectedDate, ratingsForDates: ratingsForDates)
             //    .padding(.top, 8)
             
             CalendarViewRepresentable(
                             selectedDate: $selectedDate,
                             selectedRange: $selectedRange
                         ).padding(.top, 8)
             
             
             // データあり・なしで同じ枠を維持
             Group {
                 if let item = selectedItem {
                     VStack(spacing: 12) {
                         HStack {
                             Text(ratingEmoji(for: item.rating))
                                 .font(.system(size: 48))
                                 .frame(width: 60)
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
                         // 2×2グリッドでグループを並べる
                         VStack(spacing: 12) {
                             ForEach(0..<groupMatrix.count, id: \.self) { row in
                                 HStack(spacing: 12) {
                                     ForEach(0..<groupMatrix[row].count, id: \.self) { col in
                                         let group = groupMatrix[row][col]
                                         VStack(alignment: .center, spacing: 6) {
                                             Text(group.name)
                                                 .font(.caption)
                                                 .foregroundColor(.white)
                                                 .padding(.bottom, 4)
                                             // ★ グリッドの高さを固定し、常に同じ大きさに
                                             LazyVGrid(
                                                 columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3),
                                                 spacing: 6
                                             ) {
                                                 ForEach(group.emotions) { emotion in
                                                     // 感情がその日に記録されていれば選択可能、なければグレーアウト
                                                     let isActive = item.emotions.contains(emotion.name)
                                                     Button(action: {
                                                         if isActive {
                                                             selectedEmotion = (selectedEmotion == emotion.name) ? nil : emotion.name
                                                         }
                                                     }) {
                                                         VStack {
                                                             Circle()
                                                                 .fill(isActive ? emotion.color : Color.gray.opacity(0.3))
                                                                 .overlay(
                                                                     Circle()
                                                                         .stroke(selectedEmotion == emotion.name ? Color.white : Color.clear, lineWidth: 2)
                                                                 )
                                                                 .frame(width: 16, height: 16) // ← 小さめに
                                                             Text(emotion.name)
                                                                 .font(.system(size: 8))
                                                                 .foregroundColor(isActive ? .white : .gray)
                                                                 .multilineTextAlignment(.center)
                                                         }
                                                     }
                                                     .buttonStyle(.plain)
                                                     .disabled(!isActive)
                                                 }
                                             }
                                             .frame(height: 3 * (16 + 16) + 12) // 3行分の高さ＋余白で常に同じ
                                         }
                                         .padding(6)
                                         .background(
                                             RoundedRectangle(cornerRadius: 14)
                                                 .stroke(Color.white.opacity(0.25), lineWidth: 2)
                                         )
                                         .frame(width: 160, height: 140) // ← グループごとに固定サイズ
                                     }
                                 }
                             }
                         }
                         .padding(.top, 4)
                         
                         // 選択中の感情メモ表示
                         if let emotion = selectedEmotion,
                            let note = item.emotionNotes[emotion],
                            !note.isEmpty {
                             VStack(alignment: .leading, spacing: 6) {
                                 HStack(spacing: 8) {
                                     Circle()
                                         .fill(emotionColor(for: emotion))
                                         .frame(width: 20, height: 20)
                                     Text(emotion)
                                         .font(.headline)
                                         .foregroundColor(emotionColor(for: emotion))
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
                 } else  {
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
                         Spacer().frame(height: 32)
                     }
                 }
             }
             .padding()
             .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
             .padding(.horizontal)
             .frame(minHeight: 100)
             .transition(.slide)
             
             Spacer(minLength: 24) // ← 最下部に余白
         }
         .padding(.horizontal)
         .padding(.top, 8)
         .safeAreaInset(edge: .bottom) {
             Color.clear.frame(height: 44) // TabBar分の余白
         }
         .background(Color(.systemBackground))
         .ignoresSafeArea(.keyboard, edges: .bottom) // ← 必要に応じて（キーボード入力時のみ）
         // 編集シート
         .sheet(isPresented: $showEditor) {
             NavigationStack {
                 RecordEditorView(
                     selectedDate: $selectedDate,
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

 /*
 // プレビュー例
 #Preview {
     CalendarView(
         selectedDate: .constant(Date()),
         selectedTab: .constant(0),
         ratingsForDates: [
             Calendar.current.startOfDay(for: Date()): 5,
             Calendar.current.startOfDay(for: Date().addingTimeInterval(-86400)): 3
         ],
         items: [
             Item(
                 timestamp: Date(),
                 rating: 5,
                 memoText: "Test",
                 emotions: ["Happy", "Excited", "Calm", "Creative", "Energetic"],
                 emotionNotes: [
                     "Happy": "友達と楽しい時間を過ごした",
                     "Excited": "新しいことに挑戦した！",
                     "Calm": "ゆっくり本を読んだ"
                 ]
             )
         ]
     )
 }
 */

 */
