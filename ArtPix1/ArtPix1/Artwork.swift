import Foundation
import FirebaseFirestore
import CoreLocation

struct Artwork: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var price: Double
    var currency: String
    var imageURL: String
    var address: String
    var latitude: Double
    var longitude: Double
}
