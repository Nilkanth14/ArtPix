import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = true

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome, \(Auth.auth().currentUser?.email ?? "User")")
                .font(.headline)

            Button("Logout") {
                logout()
            }
            .foregroundColor(.red)
        }
        .padding()
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }
    }
}
