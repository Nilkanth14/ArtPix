import SwiftUI

struct SuccessPopupView: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            VStack(spacing: 20) {
                Text("🎉")
                    .font(.system(size: 60))
                    .scaleEffect(isVisible ? 1 : 0.5)
                    .animation(.easeInOut(duration: 0.4), value: isVisible)

                Text("Uploaded Successfully!")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.green)
            .cornerRadius(16)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
        }
    }
}
