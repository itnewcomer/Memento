/*
import SwiftUI

struct LineChartView: View {
    var data: [Int]
    let maxValue: Int

    init(data: [Int], maxValue: Int = 5) {
        self.data = data
        self.maxValue = maxValue
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if data.count > 1 && maxValue > 0 {
                    Path { path in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let stepY = geometry.size.height / CGFloat(maxValue)
                        for (index, value) in data.enumerated() {
                            let x = stepX * CGFloat(index)
                            let y = geometry.size.height - stepY * CGFloat(value)
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)

                    ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                        let stepX = geometry.size.width / CGFloat(data.count - 1)
                        let stepY = geometry.size.height / CGFloat(maxValue)
                        let x = stepX * CGFloat(index)
                        let y = geometry.size.height - stepY * CGFloat(value)
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                    }
                } else {
                    // データがない場合のダミー表示
                    Text("データなし")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
}
*/
