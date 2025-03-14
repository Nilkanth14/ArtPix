import SwiftUI
import FirebaseFirestore

struct GalleryView: View {
    @State private var artworks = [Artwork]()
    @State private var errorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("ArtPix1")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)

                Spacer()

                Button(action: {
                    print("Notifications Tapped")
                }) {
                    Image(systemName: "bell")
                        .font(.title2)
                }
            }
            .padding([.horizontal, .top])

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Text("#Nature")
                    Text("#Photography")
                    Text("#Artworks")
                    Text("#Trending")
                }
                .padding(.horizontal)
                .foregroundColor(.blue)
            }

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(artworks) { artwork in
                        VStack(alignment: .leading, spacing: 8) {
                            if let imageUrl = URL(string: artwork.imageURL) {
                                AsyncImage(url: imageUrl) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width / 2 - 24, height: 180)
                                        .clipped()
                                        .cornerRadius(12)
                                        .shadow(radius: 5)
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            Text(artwork.title)
                                .font(.headline)
                                .lineLimit(1)
                                .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            listenToArtworks()
        }
    }

    func listenToArtworks() {
        Firestore.firestore().collection("artworks").addSnapshotListener { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch artworks: \(error.localizedDescription)"
                return
            }

            self.artworks = snapshot?.documents.compactMap {
                try? $0.data(as: Artwork.self)
            } ?? []
        }
    }
}
