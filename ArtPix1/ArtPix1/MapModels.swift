import Foundation
import MapKit

struct MapPoint: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
