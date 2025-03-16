import FirebaseFirestore

struct Comment: Codable, Identifiable {
    @DocumentID var id: String? // Let Firestore manage this automatically
    var userId: String
    var username: String
    var text: String
    var timestamp: Date
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
