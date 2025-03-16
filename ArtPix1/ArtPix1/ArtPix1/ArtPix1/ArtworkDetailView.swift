import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

// MARK: - Artwork Detail View Model
class ArtworkDetailViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private let artworkId: String
    private var userId: String {
        return Auth.auth().currentUser?.uid ?? "unknown_user"
    }

    @Published var comments: [Comment] = []
    @Published var isLiked: Bool = false
    @Published var likeCount: Int = 0
    @Published var isLoading: Bool = true

    init(artworkId: String) {
        self.artworkId = artworkId
        fetchData()
    }

    func fetchData() {
        fetchComments()
        fetchLikes()
    }

    func fetchComments() {
        db.collection("artworks").document(artworkId).collection("comments")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching comments: \(error.localizedDescription)")
                    return
                }

                self.comments = snapshot?.documents.compactMap { document -> Comment? in
                    try? document.data(as: Comment.self)
                } ?? []

                print("Comments updated: \(self.comments)")
                self.isLoading = false
            }
    }

    func fetchLikes() {
        let artworkRef = db.collection("artworks").document(artworkId)

        artworkRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let data = snapshot?.data() else { return }
            self.likeCount = data["likeCount"] as? Int ?? 0
        }

        artworkRef.collection("likes").document(userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLiked = snapshot?.exists ?? false
            }
    }

    func toggleLike() {
        let artworkRef = db.collection("artworks").document(artworkId)
        let userLikeRef = artworkRef.collection("likes").document(userId)

        userLikeRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }

            if let document = document, document.exists {
                userLikeRef.delete()
                artworkRef.updateData(["likeCount": FieldValue.increment(Int64(-1))])
                self.isLiked = false
                self.likeCount = max(0, self.likeCount - 1)
            } else {
                userLikeRef.setData(["timestamp": FieldValue.serverTimestamp()])
                artworkRef.updateData(["likeCount": FieldValue.increment(Int64(1))])
                self.isLiked = true
                self.likeCount += 1
            }
        }
    }

    // Add a new comment
        func addComment(text: String) {
            let commentId = UUID().uuidString
            let newComment = Comment(
                id: commentId,
                userId: userId,
                username: "Neel", // Replace with real user info
                text: text,
                timestamp: Date()
            )

            do {
                try db.collection("artworks").document(artworkId)
                    .collection("comments")
                    .document(commentId)
                    .setData(from: newComment)
            } catch {
                print("Error adding comment: \(error.localizedDescription)")
            }
        }
    }

    // View for a single comment row
    struct CommentRowView: View {
        let comment: Comment
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.username)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(comment.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(comment.text)
                    .font(.body)
                    .padding(.top, 2)
            }
            .padding(.vertical, 8)
        }
    }

    // View for all comments
    struct AllCommentsView: View {
        @ObservedObject var viewModel: ArtworkDetailViewModel
        @Environment(\.dismiss) private var dismiss
        @State private var newComment = ""
        @FocusState private var isCommentFieldFocused: Bool
        
        var body: some View {
            NavigationView {
                VStack {
                    // Comments list
                    if viewModel.comments.isEmpty {
                        VStack {
                            Spacer()
                            Text("No comments yet")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(viewModel.comments) { comment in
                                CommentRowView(comment: comment)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                    
                    // Comment input field
                    VStack {
                        Divider()
                        HStack {
                            TextField("Add a comment...", text: $newComment)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .focused($isCommentFieldFocused)
                            
                            Button {
                                if !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    viewModel.addComment(text: newComment)
                                    newComment = ""
                                    isCommentFieldFocused = false
                                }
                            } label: {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.blue)
                                    .padding(8)
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Comments")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }


// MARK: - Artwork Detail View
struct ArtworkDetailView: View {
    let artwork: Artwork
    @StateObject private var viewModel: ArtworkDetailViewModel
    @State private var mapPosition: MapCameraPosition
    @State private var showCommentsView = false
    @State private var newComment = ""
    @FocusState private var isCommentFieldFocused: Bool

    init(artwork: Artwork) {
        self.artwork = artwork
        _viewModel = StateObject(wrappedValue: ArtworkDetailViewModel(artworkId: artwork.id ?? "unknown"))

        _mapPosition = State(initialValue: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: artwork.latitude, longitude: artwork.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Artwork Image
                AsyncImage(url: URL(string: artwork.imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFit().cornerRadius(12).frame(maxHeight: 300)
                    default:
                        ProgressView().frame(height: 300)
                    }
                }

                // Title & Price
                Text(artwork.title).font(.title).fontWeight(.bold).padding(.horizontal)
                Text("\(artwork.currency) $\(artwork.price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.horizontal)

                // Like & Buy Buttons
                HStack {
                    Button(action: viewModel.toggleLike) {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(viewModel.isLiked ? .red : .primary)
                            
                            if viewModel.likeCount > 0 {
                                Text("\(viewModel.likeCount)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }

                    Spacer()

                    Button(action: { print("Buy button tapped") }) {
                        Text("Buy Now")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Location & Map
                               VStack(alignment: .leading, spacing: 8) {
                                   Text("Location").font(.headline)
                                   Text(artwork.address).foregroundColor(.gray)

                                   Map(position: $mapPosition) {
                                       Marker(artwork.address, coordinate: CLLocationCoordinate2D(latitude: artwork.latitude, longitude: artwork.longitude))
                                   }
                                   .mapStyle(.standard)
                                   .frame(height: 180)
                                   .cornerRadius(10)

                               }
                               .padding(.horizontal)


                // Comments Section
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Comments").font(.headline)

                                    if viewModel.isLoading {
                                        ProgressView().padding()
                                    } else if viewModel.comments.isEmpty {
                                        Text("No comments yet. Be the first to comment!").foregroundColor(.gray).padding(.vertical, 8)
                                    } else {
                                        if let latestComment = viewModel.comments.first {
                                            CommentRowView(comment: latestComment)
                                        }

                                        if viewModel.comments.count > 1 {
                                            Button(action: { showCommentsView = true }) {
                                                Text("View All \(viewModel.comments.count) Comments").foregroundColor(.blue)
                                            }
                                            .padding(.top, 4)
                                        }
                                    }

                                    // Add comment field
                                    HStack {
                                        TextField("Add a comment...", text: $newComment)
                                            .padding(10)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(8)
                                            .focused($isCommentFieldFocused)

                                        Button {
                                            if !newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                viewModel.addComment(text: newComment)
                                                newComment = ""
                                                isCommentFieldFocused = false
                                            }
                                        } label: {
                                            Image(systemName: "paperplane.fill").foregroundColor(.blue).padding(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .padding(.vertical)
                        }
                        .sheet(isPresented: $showCommentsView) {
                            AllCommentsView(viewModel: viewModel)
                        }
                        .navigationBarTitle("Artwork Details", displayMode: .inline)
                    }
                }
