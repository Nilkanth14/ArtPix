import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseStorage

struct UploadArtworkView: View {
    @Binding var showUploadView: Bool
    @State private var title = ""
    @State private var description = ""
    @State private var address = ""
    @State private var price: Double?
    @State private var selectedCurrency = "CAD 🇨🇦"
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showSuccessPopup = false
    
    // Address search and map
    @StateObject private var searchCompleter = AddressSearchCompleter()
    @State private var showSuggestions = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832), // Default to Toronto
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var mapIsVisible = false
    
    // Currency options
    let currencies = ["CAD 🇨🇦", "USD 🇺🇸", "EUR 🇪🇺", "GBP 🇬🇧"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Image Picker Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Artwork Image")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(height: 220)
                                .background(Color.gray.opacity(0.1).cornerRadius(12))
                            
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 220)
                                    .cornerRadius(12)
                            } else {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                    Text("Select Image")
                                        .font(.headline)
                                }
                                .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showImagePicker = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Artwork Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter artwork title", text: $title)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Describe your artwork...")
                                    .foregroundColor(.gray.opacity(0.8))
                                    .padding(.horizontal, 8)
                                    .padding(.top, 14)
                            }
                            
                            TextEditor(text: $description)
                                .padding(4)
                                .frame(height: 120)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Address Search with suggestions and map
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Location")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Search for a location", text: $address)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .onChange(of: address) { newValue in
                                searchCompleter.search(query: newValue)
                                if !newValue.isEmpty {
                                    showSuggestions = true
                                } else {
                                    showSuggestions = false
                                }
                            }
                        
                        if showSuggestions && !searchCompleter.results.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(searchCompleter.results, id: \.self) { result in
                                    Button {
                                        address = "\(result.title), \(result.subtitle)"
                                        showSuggestions = false
                                        lookupLocation(for: result)
                                    } label: {
                                        VStack(alignment: .leading) {
                                            Text(result.title)
                                                .font(.subheadline)
                                                .foregroundColor(.primary)
                                            Text(result.subtitle)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                    }
                                    Divider()
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .frame(height: min(CGFloat(searchCompleter.results.count * 50), 200))
                        }
                        
                        // Map preview when location is selected
                        if mapIsVisible, let _ = selectedLocation {
                            VStack {
                                Map(coordinateRegion: $mapRegion, annotationItems: [MapPoint(coordinate: selectedLocation!)]) { point in
                                    MapMarker(coordinate: point.coordinate, tint: .red)
                                }
                                .frame(height: 180)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .padding(.top, 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Currency and Price
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Price")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 15) {
                            // Currency picker (left-aligned)
                            Menu {
                                ForEach(currencies, id: \.self) { currencyOption in
                                    Button(currencyOption) {
                                        selectedCurrency = currencyOption
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCurrency)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            
                            // Price input with $ sign
                            HStack {
                                Text("$")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                TextField("0.00", value: $price, formatter: NumberFormatter())
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Upload Button
                    Button {
                        uploadArtwork()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Upload Artwork")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, y: 2)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.vertical)
            }
            .navigationBarTitle("Upload Artwork", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                showUploadView = false
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .overlay(
                SuccessPopupView(isVisible: $showSuccessPopup)
            )
        }
    }
    
    // Convert the search result to coordinates and update the map
    func lookupLocation(for searchCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchCompletion.title + ", " + searchCompletion.subtitle
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response, let firstItem = response.mapItems.first else {
                print("Error looking up location: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let coordinate = firstItem.placemark.coordinate
            selectedLocation = coordinate
            mapRegion = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            // Show map after a slight delay for better animation experience
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    mapIsVisible = true
                }
            }
        }
    }
    
    func uploadArtwork() {
        guard let selectedImage = selectedImage else { return }
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) else { return }
        guard !title.isEmpty, !address.isEmpty, price != nil else { return }
        
        let storageRef = Storage.storage().reference().child("artworks/\(UUID().uuidString).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            guard error == nil else { return }
            
            storageRef.downloadURL { url, _ in
                guard let downloadURL = url else { return }
                
                var artworkData: [String: Any] = [
                    "title": title,
                    "description": description,
                    "price": price ?? 0.0,
                    "currency": selectedCurrency,
                    "imageURL": downloadURL.absoluteString,
                    "address": address,
                    "timestamp": Timestamp()
                ]
                
                // Add coordinates if available
                if let location = selectedLocation {
                    artworkData["latitude"] = location.latitude
                    artworkData["longitude"] = location.longitude
                }
                
                Firestore.firestore().collection("artworks").addDocument(data: artworkData) { _ in
                    withAnimation {
                        showSuccessPopup = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            showSuccessPopup = false
                        }
                        showUploadView = false
                    }
                }
            }
        }
    }
}

// Helper struct for the map
struct MapPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - Address Search Completer
class AddressSearchCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    private let searchCompleter = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func search(query: String) {
        searchCompleter.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Address search error: \(error.localizedDescription)")
    }
}
