import SwiftUI

struct WatermarkedImage: View {
    let image: Image
    let watermarkText: String = "ArtPix"

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            image
                .resizable()
                .scaledToFit()

            Text(watermarkText)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
                .padding(5)
                .background(Color.black.opacity(0.2))
                .cornerRadius(4)
                .padding(6)
        }
    }
}
