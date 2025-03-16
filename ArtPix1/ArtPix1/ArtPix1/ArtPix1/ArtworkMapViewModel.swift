import SwiftUI
import MapKit
import FirebaseFirestore

class ArtworkMapViewModel: ObservableObject {
    @Published var artworks: [Artwork] = []
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 140, longitudeDelta: 360)
    )

    private let db = Firestore.firestore()

    init() {
        fetchArtworks()
    }

    private func fetchArtworks() {
        db.collection("artworks").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching artworks: \(error.localizedDescription)")
                return
            }

            self.artworks = snapshot?.documents.compactMap { document in
                try? document.data(as: Artwork.self)
            } ?? []
        }
    }
}
