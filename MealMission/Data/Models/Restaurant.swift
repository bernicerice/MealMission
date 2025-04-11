import Foundation

// MARK: - Restaurant Model
struct Restaurant: Identifiable, Codable {
    // MARK: - Properties
    let id: String
    let name: String
    let timeRange: String
    let likesCount: Int
    let imageURL: String
}
