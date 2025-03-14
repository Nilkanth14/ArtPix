    import SwiftUI
    import FirebaseFirestore
    import FirebaseStorage

    struct UploadArtworkView: View {
        @Binding var showUploadView: Bool
        @State private var title = ""
        @State private var description = ""
        @State private var price: Double?
        @State private var selectedImage: UIImage?
        @State private var showImagePicker = false
        @State private var showSuccessPopup = false

        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Artwork Image").font(.headline)) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                        } else {
                            Button("Select Image") {
                                showImagePicker.toggle()
                            }
                        }
                    }

                    Section(header: Text("Details").font(.headline)) {
                        TextField("Title", text: $title)
                        TextField("Description", text: $description)
                        TextField("Price", value: $price, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                    }

                    Button("Upload Artwork") {
                        uploadArtwork()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .navigationBarTitle("Upload Artwork", displayMode: .inline)
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $selectedImage)
                }
                .overlay(
                    SuccessPopupView(isVisible: $showSuccessPopup)
                        .animation(.spring(), value: showSuccessPopup),
                    alignment: .center
                )
            }
        }

        func uploadArtwork() {
            guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }

            let storageRef = Storage.storage().reference().child("artworks/\(UUID().uuidString).jpg")
            storageRef.putData(imageData, metadata: nil) { _, error in
                guard error == nil else { return }

                storageRef.downloadURL { url, _ in
                    guard let downloadURL = url else { return }

                    let artworkData = [
                        "title": title,
                        "description": description,
                        "price": price ?? 0.0,
                        "imageURL": downloadURL.absoluteString,
                        "timestamp": Timestamp()
                    ] as [String: Any]

                    Firestore.firestore().collection("artworks").addDocument(data: artworkData) { _ in
                        showSuccessPopup = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSuccessPopup = false
                            showUploadView = false
                        }
                    }
                }
            }
        }
    }
