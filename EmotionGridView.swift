import SwiftUI

struct EmotionGridView: View {
    let group: EmotionGroup
    let item: Item
    @Binding var selectedEmotion: String?

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(group.name)
                .font(.caption)
                .foregroundColor(.white)
                .padding(.bottom, 4)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 3),
                spacing: 6
            ) {
                ForEach(group.emotions) { emotion in
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
                                .frame(width: 16, height: 16)
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
            .frame(height: 3 * (16 + 16) + 12)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.25), lineWidth: 2)
        )
        .frame(width: 160, height: 148)
    }
}
