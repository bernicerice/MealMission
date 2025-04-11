import Foundation

// MARK: - RestourantCellModel
struct RestourantCellModel {
    // MARK: - Properties
    let imageURL: String
    let title: String
    let timeRange: String
    let likesCount: Int
    
    // MARK: - Initializers
    init(from restaurant: Restaurant) {
        self.imageURL = restaurant.imageURL
        self.title = restaurant.name
        self.timeRange = restaurant.timeRange
        self.likesCount = restaurant.likesCount
    }
    
    init(imageURL: String, title: String, timeRange: String, likesCount: Int) {
        self.imageURL = imageURL
        self.title = title
        self.timeRange = timeRange
        self.likesCount = likesCount
    }
} 
