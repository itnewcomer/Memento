import SwiftUI

// --- モデル定義 ---

struct MonthlyGoal: Identifiable, Codable, Equatable {
    let id: UUID
    let year: Int
    let month: Int
    var excitedGoals: [GoalTask]
    var stretchGoals: [GoalTask]
    var tasks: [GoalTask]
    var letterToSelf: String
}

struct GoalTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

// --- GoalMonthSelector (Date?対応) ---

struct GoalMonthSelector: View {
    @Binding var selectedDate: Date?

    private let calendar = Calendar.current
    private let years: [Int]
    private let months: [Int] = Array(1...12)

    init(selectedDate: Binding<Date?>) {
        self._selectedDate = selectedDate
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

    private var yearBinding: Binding<Int> {
        Binding<Int>(
            get: {
                if let selectedDate = selectedDate {
                    return calendar.component(.year, from: selectedDate)
                } else {
                    return calendar.component(.year, from: Date())
                }
            },
            set: { newYear in
                let month = selectedDate.flatMap { calendar.component(.month, from: $0) } ?? 1
                if let newDate = calendar.date(from: DateComponents(year: newYear, month: month, day: 1)) {
                    selectedDate = newDate
                }
            }
        )
    }
    private var monthBinding: Binding<Int> {
        Binding<Int>(
            get: {
                if let selectedDate = selectedDate {
                    return calendar.component(.month, from: selectedDate)
                } else {
                    return 1
                }
            },
            set: { newMonth in
                let year = selectedDate.flatMap { calendar.component(.year, from: $0) } ?? calendar.component(.year, from: Date())
                if let newDate = calendar.date(from: DateComponents(year: year, month: newMonth, day: 1)) {
                    selectedDate = newDate
                }
            }
        )
    }
}

// --- 目標編集サブビュー ---

struct GoalEditor: View {
    @Binding var goal: MonthlyGoal
    @Binding var showLetterSheet: Bool

    var ratingsForDates: [Date: Int]
    var items: [Item]
    var emotionDict: [String: Emotion]

    @State private var newExcitedGoal = ""
    @State private var newStretchGoal = ""
    @State private var newTaskTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Excited Goals
            Text("Excited Goals（ワクワク目標・最大5つ）").font(.headline)
            ForEach($goal.excitedGoals) { $goalTask in
                HStack {
                    Button(action: { goalTask.isCompleted.toggle() }) {
                        Image(systemName: goalTask.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(goalTask.isCompleted ? .green : .gray)
                    }
                    Text(goalTask.title)
                        .strikethrough(goalTask.isCompleted)
                        .foregroundColor(goalTask.isCompleted ? .gray : .primary)
                    Spacer()
                    Button(action: {
                        goal.excitedGoals.removeAll { $0.id == goalTask.id }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            if goal.excitedGoals.count < 5 {
                HStack {
                    TextField("新しいワクワク目標", text: $newExcitedGoal)
                        .textFieldStyle(.roundedBorder)
                    Button("追加") {
                        let trimmed = newExcitedGoal.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        goal.excitedGoals.append(GoalTask(id: UUID(), title: trimmed, isCompleted: false))
                        newExcitedGoal = ""
                    }
                    .buttonStyle(.bordered)
                }
            }

            Divider()

            // Stretch Goals
            Text("Stretch Goals（ストレッチ目標・最大5つ）").font(.headline)
            ForEach($goal.stretchGoals) { $goalTask in
                HStack {
                    Button(action: { goalTask.isCompleted.toggle() }) {
                        Image(systemName: goalTask.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(goalTask.isCompleted ? .green : .gray)
                    }
                    Text(goalTask.title)
                        .strikethrough(goalTask.isCompleted)
                        .foregroundColor(goalTask.isCompleted ? .gray : .primary)
                    Spacer()
                    Button(action: {
                        goal.stretchGoals.removeAll { $0.id == goalTask.id }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            if goal.stretchGoals.count < 5 {
                HStack {
                    TextField("新しいストレッチ目標", text: $newStretchGoal)
                        .textFieldStyle(.roundedBorder)
                    Button("追加") {
                        let trimmed = newStretchGoal.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        goal.stretchGoals.append(GoalTask(id: UUID(), title: trimmed, isCompleted: false))
                        newStretchGoal = ""
                    }
                    .buttonStyle(.bordered)
                }
            }

            Divider()

            // Tasks (ToDo)
            Text("Task（ToDo・最大20個）").font(.headline)
            ForEach($goal.tasks) { $task in
                HStack {
                    Button(action: { task.isCompleted.toggle() }) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                    }
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                    Spacer()
                    Button(action: {
                        goal.tasks.removeAll { $0.id == task.id }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            if goal.tasks.count < 20 {
                HStack {
                    TextField("新しいタスク", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    Button("追加") {
                        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        goal.tasks.append(GoalTask(id: UUID(), title: trimmed, isCompleted: false))
                        newTaskTitle = ""
                    }
                    .buttonStyle(.bordered)
                }
            }

            Divider()


        }
        .padding()
    }
}

// --- GoalView本体 ---

struct GoalView: View {
    @Binding var selectedDate: Date?
    @AppStorage("monthlyGoals") private var monthlyGoalsData: Data = Data()
    @State private var monthlyGoals: [MonthlyGoal] = []
    @State private var showLetterSheet = false

    var ratingsForDates: [Date: Int]
    var items: [Item]
    var emotionDict: [String: Emotion]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                GoalMonthSelector(selectedDate: $selectedDate)

                if let goal = goalForMonth {
                    GoalEditor(
                        goal: binding(for: goal),
                        showLetterSheet: .constant(false), // 編集は鉛筆ボタンで
                        ratingsForDates: ratingsForDates,
                        items: items,
                        emotionDict: emotionDict
                    )

                    Divider()
                    // 手紙プレビュー＆編集ボタン
                    HStack {
                        Text("自分への手紙（大事な友人や恋人、家族に送るように自分に優しい言葉をかけてね）")
                            .font(.headline)
                        Spacer()
                        Button(action: { showLetterSheet = true }) {
                            Image(systemName: "pencil")
                                .imageScale(.large)
                        }
                        .accessibilityLabel("編集") // 必要なら[2][3]
                    }
                    .padding(.bottom, 2)
                    if goal.letterToSelf.isEmpty {
                        Text("未記入")
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                    } else {
                        Text(goal.letterToSelf)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                    }
                }else {
                    Button("この月の目標を作成") {
                        createGoalForMonth()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer(minLength: 40)
            }
            .padding()
        }
        .navigationTitle("Goal")
        .onAppear(perform: loadGoals)
        .onChange(of: monthlyGoals) { _, _ in
            saveGoals()
        }
        .sheet(isPresented: $showLetterSheet) {
            if let idx = monthlyGoals.firstIndex(where: { $0.year == selectedYear && $0.month == selectedMonth }) {
                LetterComposeView(
                    selectedDate: selectedDate,
                    ratingsForDates: ratingsForDates,
                    items: items,
                    emotionDict: emotionDict,
                    goal: $monthlyGoals[idx],
                    onSave: { showLetterSheet = false }
                )
            }
        }
    }

    // 今月の目標を取得
    private var goalForMonth: MonthlyGoal? {
        guard let selectedDate = selectedDate else { return nil }
        let comps = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        return monthlyGoals.first { $0.year == comps.year && $0.month == comps.month }
    }

    // Binding取得
    private func binding(for goal: MonthlyGoal) -> Binding<MonthlyGoal> {
        guard let idx = monthlyGoals.firstIndex(where: { $0.id == goal.id }) else {
            fatalError("Goal not found")
        }
        return $monthlyGoals[idx]
    }

    // 目標新規作成
    private func createGoalForMonth() {
        guard let selectedDate = selectedDate else { return }
        let comps = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        let newGoal = MonthlyGoal(
            id: UUID(),
            year: comps.year ?? 2024,
            month: comps.month ?? 1,
            excitedGoals: [],
            stretchGoals: [],
            tasks: [],
            letterToSelf: ""
        )
        monthlyGoals.append(newGoal)
    }

    // --- 保存・読み込み ---
    private func loadGoals() {
        guard !monthlyGoalsData.isEmpty,
              let decoded = try? JSONDecoder().decode([MonthlyGoal].self, from: monthlyGoalsData)
        else { return }
        monthlyGoals = decoded
    }

    private func saveGoals() {
        if let data = try? JSONEncoder().encode(monthlyGoals) {
            monthlyGoalsData = data
        }
    }

    private var selectedYear: Int {
        guard let selectedDate = selectedDate else { return 2024 }
        return Calendar.current.component(.year, from: selectedDate)
    }
    private var selectedMonth: Int {
        guard let selectedDate = selectedDate else { return 1 }
        return Calendar.current.component(.month, from: selectedDate)
    }
}
