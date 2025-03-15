import Foundation
import FirebaseFirestore

struct Artwork: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var price: Double
    var imageURL: String
    var address: String 
}
