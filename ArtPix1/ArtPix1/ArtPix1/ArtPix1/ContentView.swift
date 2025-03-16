import SwiftUI
import MapKit
import FirebaseFirestore

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var showUploadView = false

    var body: some View {
        NavigationStack {
            if isLoggedIn {
                MainTabView(showUploadView: $showUploadView)
            } else {
                LoginView()
            }
        }
    }
}

struct MainTabView: View {
    @Binding var showUploadView: Bool
    @State private var showFullScreenMap = false

    var body: some View {
        TabView {
            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                }

            MarketplaceView()
                .tabItem {
                    Label("Marketplace", systemImage: "cart")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
        .overlay(
            HStack(spacing: 20) {
                FloatingButton(icon: "map", action: {
                    showFullScreenMap.toggle()
                })
                .fullScreenCover(isPresented: $showFullScreenMap) {
                    FullScreenMapView()
                }

                FloatingButton(icon: "plus", action: {
                    showUploadView.toggle()
                })
                .sheet(isPresented: $showUploadView) {
                    UploadArtworkView(showUploadView: $showUploadView)
                }
            }
            .padding(.bottom, 80), alignment: .bottom
        )
    }
}

struct FloatingButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
}
