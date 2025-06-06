import SwiftUI

struct LetterComposeView: View {
    let selectedDate: Date?
    let ratingsForDates: [Date: Int]
    let items: [Item]
    let emotionDict: [String: Emotion]
    @Binding var goal: MonthlyGoal
    var onSave: () -> Void

    @State private var draftLetter: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("今月の振り返り").font(.title2).bold()

                // 月間チャート
                MonthlyLineChartView(
                    selectedDate: selectedDate,
                    ratingsForDates: ratingsForDates,
                    selectedDay: .constant(nil)
                )
                .frame(height: 180)

                // 100%横棒
                DistributionBarView(
                    reportType: .monthly,
                    selectedDate: selectedDate,
                    ratingsForDates: ratingsForDates
                )

                // タグごとの感情分析
                TagEmotionAnalysisView(
                    reportType: .monthly,
                    selectedDate: selectedDate,
                    items: items,
                    emotionDict: emotionDict,
                    onDotTap: { _, _ in }
                )

                Divider()

                // 目標達成状況
                GoalAchievementView(goal: $goal)

                Divider()

                // 手紙編集欄
                Text("自分への手紙")
                    .font(.headline)
                TextEditor(text: $draftLetter)
                    .frame(minHeight: 120, maxHeight: 180)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                Button("保存") {
                    goal.letterToSelf = draftLetter
                    onSave()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
            }
            .padding()
            .onAppear {
                draftLetter = goal.letterToSelf
            }
        }
    }
}

// 目標達成状況サブビュー
struct GoalAchievementView: View {
    @Binding var goal: MonthlyGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Excited Goals")
                .font(.subheadline).bold()
            ForEach($goal.excitedGoals) { $g in
                HStack {
                    Button(action: { g.isCompleted.toggle() }) {
                        Image(systemName: g.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(g.isCompleted ? .green : .gray)
                    }
                    Text(g.title)
                        .strikethrough(g.isCompleted)
                }
            }
            Text("Stretch Goals")
                .font(.subheadline).bold()
            ForEach($goal.stretchGoals) { $g in
                HStack {
                    Button(action: { g.isCompleted.toggle() }) {
                        Image(systemName: g.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(g.isCompleted ? .green : .gray)
                    }
                    Text(g.title)
                        .strikethrough(g.isCompleted)
                }
            }
            Text("Tasks")
                .font(.subheadline).bold()
            ForEach($goal.tasks) { $t in
                HStack {
                    Button(action: { t.isCompleted.toggle() }) {
                        Image(systemName: t.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(t.isCompleted ? .green : .gray)
                    }
                    Text(t.title)
                        .strikethrough(t.isCompleted)
                }
            }
        }
    }
}
