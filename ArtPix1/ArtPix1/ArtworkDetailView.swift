import SwiftUI
import MapKit

struct ArtworkDetailView: View {
    let artwork: Artwork
    @State private var coordinate: CLLocationCoordinate2D? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageUrl = URL(string: artwork.imageURL) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    } placeholder: {
                        ProgressView()
                    }
                }

                Text(artwork.title).font(.title).bold()
                Text(artwork.description).font(.body)

                if let coordinate = coordinate {
                    Map {
                        Marker("Artwork Location", coordinate: coordinate)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                }
            }
            .padding()
            .onAppear {
                getCoordinateFrom(address: artwork.address)
            }
        }
    }

    private func getCoordinateFrom(address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first, let location = placemark.location {
                coordinate = location.coordinate
            }
        }
    }
}
