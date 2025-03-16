import SwiftUI
import Firebase

@main
struct ArtPix1App: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
