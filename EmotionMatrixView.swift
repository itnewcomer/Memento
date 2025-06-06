import SwiftUI

// --- データモデル ---
struct Emotion: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let color: Color
}

struct EmotionGroup: Identifiable {
    let id = UUID()
    let name: String
    let emotions: [Emotion]
}

// --- グループ定義（管理・集計用） ---
let emotionGroups: [EmotionGroup] = [
    EmotionGroup(name: "落ち着き・安心", emotions: [
        Emotion(name: "Peaceful", color: Color(red:0.70, green:0.90, blue:0.80)),
        Emotion(name: "Grateful", color: Color(red:0.80, green:0.93, blue:0.74)),
        Emotion(name: "Awe", color: Color(red:0.99, green:0.96, blue:0.77)),
        Emotion(name: "Safe", color: Color(red:0.74, green:0.90, blue:0.85)),
        Emotion(name: "Calm", color: Color(red:0.73, green:0.91, blue:0.91)),
        Emotion(name: "Curious", color: Color(red:0.87, green:0.97, blue:0.82)),
        Emotion(name: "Cozy", color: Color(red:0.75, green:0.88, blue:0.80)),
        Emotion(name: "Chill", color: Color(red:0.72, green:0.87, blue:0.89)),
        Emotion(name: "Fine", color: Color(red:0.92, green:0.96, blue:0.85))
    ]),
    EmotionGroup(name: "活発・ポジティブ", emotions: [
        Emotion(name: "Love", color: Color(red:1.00, green:0.91, blue:0.70)),
        Emotion(name: "Connected", color: Color(red:1.00, green:0.91, blue:0.70)),
        Emotion(name: "Joy", color: Color(red:1.00, green:0.89, blue:0.53)),
        Emotion(name: "Creative", color: Color(red:0.99, green:0.95, blue:0.76)),
        Emotion(name: "Happy", color: Color(red:1.00, green:0.95, blue:0.65)),
        Emotion(name: "Excited", color: Color(red:1.00, green:0.88, blue:0.51)),
        Emotion(name: "Pleasant", color: Color(red:0.99, green:0.95, blue:0.78)),
        Emotion(name: "Silly", color: Color(red:1.00, green:0.93, blue:0.72)),
        Emotion(name: "Energetic", color: Color(red:1.00, green:0.80, blue:0.44))
    ]),
    EmotionGroup(name: "落ち込み・内向き", emotions: [
        Emotion(name: "Tired", color: Color(red:0.59, green:0.76, blue:0.92)),
        Emotion(name: "Disappointed", color: Color(red:0.51, green:0.68, blue:0.88)),
        Emotion(name: "Bored", color: Color(red:0.60, green:0.72, blue:0.82)),
        Emotion(name: "Miserable", color: Color(red:0.44, green:0.63, blue:0.88)),
        Emotion(name: "Sad", color: Color(red:0.38, green:0.54, blue:0.80)),
        Emotion(name: "Shy", color: Color(red:0.56, green:0.69, blue:0.89)),
        Emotion(name: "Depressed", color: Color(red:0.30, green:0.43, blue:0.70)),
        Emotion(name: "Lonely", color: Color(red:0.33, green:0.47, blue:0.74)),
        Emotion(name: "Ashamed", color: Color(red:0.51, green:0.56, blue:0.80))
    ]),
    EmotionGroup(name: "不快・怒り", emotions: [
        Emotion(name: "Annoyed", color: Color(red:0.98, green:0.70, blue:0.61)),
        Emotion(name: "Frustrated", color: Color(red:0.98, green:0.63, blue:0.49)),
        Emotion(name: "Rowdy", color: Color(red:1.00, green:0.46, blue:0.26)),
        Emotion(name: "Embarrassed", color: Color(red:0.98, green:0.76, blue:0.67)),
        Emotion(name: "Angry", color: Color(red:1.00, green:0.46, blue:0.26)),
        Emotion(name: "Stressed", color: Color(red:1.00, green:0.36, blue:0.22)),
        Emotion(name: "Anxious", color: Color(red:0.98, green:0.70, blue:0.61)),
        Emotion(name: "Jealous", color: Color(red:1.00, green:0.46, blue:0.26)),
        Emotion(name: "Furious", color: Color(red:1.00, green:0.22, blue:0.19))
    ])
]

// --- 紙の順番でEmotionを並べる ---
let emotionOrder: [String] = [
    // 1行目
    "Peaceful", "Grateful", "Awe", "Love", "Connected", "Joy",
    // 2行目
    "Safe", "Calm", "Curious", "Creative", "Happy", "Excited",
    // 3行目
    "Cozy", "Chill", "Fine", "Pleasant", "Silly", "Energetic",
    // 4行目
    "Tired", "Disappointed", "Bored", "Annoyed", "Frustrated", "Rowdy",
    // 5行目
    "Miserable", "Sad", "Shy", "Embarrassed", "Angry", "Stressed",
    // 6行目
    "Depressed", "Lonely", "Ashamed", "Anxious", "Jealous", "Furious"
]

// --- Emotion nameからEmotionを引く辞書を作成 ---
let emotionDict: [String: Emotion] = emotionGroups.flatMap { $0.emotions }.reduce(into: [:]) { $0[$1.name] = $1 }

// --- 紙の順番で6×6グリッドを作成 ---
let emotionRows: [[Emotion]] = stride(from: 0, to: emotionOrder.count, by: 6).map { i in
    (0..<6).compactMap { j in
        let idx = i + j
        guard idx < emotionOrder.count else { return nil }
        return emotionDict[emotionOrder[idx]]
    }
}

// --- グループタイトルと色（枠用） ---
let groupTitles = [
    "落ち着き・安心",
    "活発・ポジティブ",
    "落ち込み・内向き",
    "不快・怒り"
]
let groupColors: [Color] = [.green, .yellow, .teal, .orange]

// --- EmotionMatrixView本体 ---
struct EmotionMatrixView: View {
    let emotionRows: [[Emotion]]
    let emotionGroups: [EmotionGroup]
    @Binding var selectedEmotions: Set<String>
    
    private let cellWidth: CGFloat = 60
    private let cellHeight: CGFloat = 60
    private let gridSpacing: CGFloat = 5
    
    var body: some View {
        ZStack {
            // グループ枠
            Group {
                // 左上
                RoundedRectangle(cornerRadius: 12)
                    .stroke(groupColors[0].opacity(0.7), lineWidth: 2)
                    .frame(width: 3*cellWidth + 2*gridSpacing, height: 3*cellHeight + 2*gridSpacing)
                    .position(x: (3*cellWidth + 2*gridSpacing)/2, y: (3*cellHeight + 2*gridSpacing)/2)
                // 右上
                RoundedRectangle(cornerRadius: 12)
                    .stroke(groupColors[1].opacity(0.7), lineWidth: 2)
                    .frame(width: 3*cellWidth + 2*gridSpacing, height: 3*cellHeight + 2*gridSpacing)
                    .position(x: (3*cellWidth + 2*gridSpacing)*1.5, y: (3*cellHeight + 2*gridSpacing)/2)
                // 左下
                RoundedRectangle(cornerRadius: 12)
                    .stroke(groupColors[2].opacity(0.7), lineWidth: 2)
                    .frame(width: 3*cellWidth + 2*gridSpacing, height: 3*cellHeight + 2*gridSpacing)
                    .position(x: (3*cellWidth + 2*gridSpacing)/2, y: (3*cellHeight + 2*gridSpacing)*1.5)
                // 右下
                RoundedRectangle(cornerRadius: 12)
                    .stroke(groupColors[3].opacity(0.7), lineWidth: 2)
                    .frame(width: 3*cellWidth + 2*gridSpacing, height: 3*cellHeight + 2*gridSpacing)
                    .position(x: (3*cellWidth + 2*gridSpacing)*1.5, y: (3*cellHeight + 2*gridSpacing)*1.5)
            }
            
            // 6×6グリッド本体
            VStack(spacing: gridSpacing) {
                ForEach(0..<emotionRows.count, id: \.self) { row in
                    HStack(spacing: gridSpacing) {
                        ForEach(emotionRows[row]) { emotion in
                            Button(action: {
                                if selectedEmotions.contains(emotion.name) {
                                    selectedEmotions.remove(emotion.name)
                                } else {
                                    selectedEmotions.insert(emotion.name)
                                }
                            }) {
                                VStack(spacing: 2) {
                                    Circle()
                                        .fill(emotion.color)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedEmotions.contains(emotion.name) ? Color.white : Color.clear, lineWidth: 2)
                                        )
                                        .frame(width: 24, height: 24)
                                    Text(emotion.name)
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .frame(height: 18)
                                }
                                .frame(width: cellWidth, height: cellHeight)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // グループタイトル
            VStack {
                HStack {
                    Text(groupTitles[0])
                        .font(.caption).bold().foregroundColor(groupColors[0])
                        .frame(width: 3*cellWidth)
                    Spacer()
                    Text(groupTitles[1])
                        .font(.caption).bold().foregroundColor(groupColors[1])
                        .frame(width: 3*cellWidth)
                }
                .padding(.top, -18)
                Spacer()
                HStack {
                    Text(groupTitles[2])
                        .font(.caption).bold().foregroundColor(groupColors[2])
                        .frame(width: 3*cellWidth)
                    Spacer()
                    Text(groupTitles[3])
                        .font(.caption).bold().foregroundColor(groupColors[3])
                        .frame(width: 3*cellWidth)
                }
                .padding(.bottom, -18)
            }
            .frame(width: 6*cellWidth + 5*gridSpacing, height: 6*cellHeight + 5*gridSpacing)
        }
        .frame(width: 6*cellWidth + 5*gridSpacing, height: 6*cellHeight + 5*gridSpacing)
        .padding()
    }
}

