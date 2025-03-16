import SwiftUI
import MapKit
import FirebaseFirestore

struct FullScreenMapView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ArtworkMapViewModel()
    @State private var searchText = ""
    @StateObject private var searchCompleter = AddressSearchCompleter()
    @State private var mapPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 140, longitudeDelta: 360)
        )
    )
    @State private var showSuggestions = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                Map(position: $mapPosition) {
                    ForEach(viewModel.artworks) { artwork in
                        Annotation("", coordinate: CLLocationCoordinate2D(latitude: artwork.latitude, longitude: artwork.longitude)) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                }
                .ignoresSafeArea()

                VStack {
                    TextField("Search Location", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding()
                        .onChange(of: searchText) { newValue in
                            searchCompleter.search(query: newValue)
                            showSuggestions = !newValue.isEmpty
                        }

                    if showSuggestions && !searchCompleter.results.isEmpty {
                        List(searchCompleter.results, id: \.self) { result in
                            Button(action: {
                                selectLocation(for: result)
                            }) {
                                VStack(alignment: .leading) {
                                    Text(result.title)
                                        .font(.subheadline)
                                    Text(result.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .frame(height: 200)
                    }
                }
            }
            .navigationTitle("World Map")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func selectLocation(for result: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = result.title + ", " + result.subtitle

        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else { return }
            mapPosition = .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)))
            searchText = ""
            showSuggestions = false
        }
    }
}
