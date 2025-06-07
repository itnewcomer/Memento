import SwiftUI

struct StarRatingView: View {
    @Binding var rating: Int
    let maxRating = 5
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.yellow)
                    .onTapGesture { rating = index }
            }
        }
    }
}
