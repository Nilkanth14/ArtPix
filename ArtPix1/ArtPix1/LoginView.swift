import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            Button("Login") {
                login()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text(errorMessage)
                .foregroundColor(.red)
        }
        .padding()
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.errorMessage = "Login Error: \(error.localizedDescription)"
            } else if authResult != nil {
                self.errorMessage = ""
                self.isLoggedIn = true
            } else {
                self.errorMessage = "Unknown error occurred. Try again."
            }
        }
    }
}


