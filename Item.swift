import Foundation
import SwiftData

@Model
class Item {
    var timestamp: Date
    var rating: Int
    var memoText: String
    var emotionsRaw: String
    var emotionNotesJSON: String // 追加: 感情ごとのメモをJSON形式で保存

    // emotionsの計算プロパティ（変更なし）
    var emotions: [String] {
        get { emotionsRaw.isEmpty ? [] : emotionsRaw.components(separatedBy: ",") }
        set { emotionsRaw = newValue.joined(separator: ",") }
    }

    // 感情ごとのメモを扱う計算プロパティ（追加）
    var emotionNotes: [String: String] {
        get {
            guard let data = emotionNotesJSON.data(using: .utf8),
                  let notes = try? JSONDecoder().decode([String: String].self, from: data)
            else { return [:] }
            return notes
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                emotionNotesJSON = String(data: data, encoding: .utf8) ?? "{}"
            }
        }
    }

    // イニシャライザの修正（emotionNotes追加）
    init(
        timestamp: Date,
        rating: Int = 3,
        memoText: String = "",
        emotions: [String] = [],
        emotionNotes: [String: String] = [:]
    ) {
        self.timestamp = timestamp
        self.rating = rating
        self.memoText = memoText
        self.emotionsRaw = emotions.joined(separator: ",")
        self.emotionNotesJSON = (try? JSONEncoder().encode(emotionNotes))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }
}
