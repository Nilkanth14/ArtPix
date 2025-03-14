import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @State private var isLoggedOut = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome, \(Auth.auth().currentUser?.email ?? "User")")
                .font(.headline)

            Button("Logout") {
                try? Auth.auth().signOut()
                isLoggedOut = true
            }
            .foregroundColor(.red)

            NavigationLink(destination: LoginView(), isActive: $isLoggedOut) {
                EmptyView()
            }
        }
        .padding()
    }
}
