import Foundation
import SwiftData

@Model
class Item {
    var timestamp: Date
    var rating: Int
    var memoText: String
    var emotionsRaw: String
    var emotionNotesJSON: String // 感情ごとのメモをJSON形式で保存
    var tagsRaw: String          // 全体タグをカンマ区切りで保存
    var emotionTagsJSON: String  // 感情ごとのタグをJSON形式で保存

    // emotionsの計算プロパティ
    var emotions: [String] {
        get { emotionsRaw.isEmpty ? [] : emotionsRaw.components(separatedBy: ",") }
        set { emotionsRaw = newValue.joined(separator: ",") }
    }

    // 感情ごとのメモの計算プロパティ
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

    // 全体タグの計算プロパティ
    var tags: [String] {
        get { tagsRaw.isEmpty ? [] : tagsRaw.components(separatedBy: ",") }
        set { tagsRaw = newValue.joined(separator: ",") }
    }

    // 感情ごとのタグの計算プロパティ
    var emotionTags: [String: [String]] {
        get {
            guard let data = emotionTagsJSON.data(using: .utf8),
                  let tagsDict = try? JSONDecoder().decode([String: [String]].self, from: data)
            else { return [:] }
            return tagsDict
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                emotionTagsJSON = String(data: data, encoding: .utf8) ?? "{}"
            }
        }
    }

    // イニシャライザ
    init(
        timestamp: Date,
        rating: Int = 3,
        memoText: String = "",
        emotions: [String] = [],
        emotionNotes: [String: String] = [:],
        tags: [String] = [],
        emotionTags: [String: [String]] = [:]
    ) {
        self.timestamp = timestamp
        self.rating = rating
        self.memoText = memoText
        self.emotionsRaw = emotions.joined(separator: ",")
        self.emotionNotesJSON = (try? JSONEncoder().encode(emotionNotes))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        self.tagsRaw = tags.joined(separator: ",")
        self.emotionTagsJSON = (try? JSONEncoder().encode(emotionTags))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }
}
