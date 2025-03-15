import SwiftUI

struct SuccessPopupView: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .scaleEffect(isVisible ? 1 : 0.5)
                    .animation(.spring(), value: isVisible)

                Text("Uploaded Successfully!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
            }
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(16)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 40)
            .transition(.scale)
        }
    }
}
