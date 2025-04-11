import Foundation
import SwiftUI

@MainActor
final class RestourantCellViewModel: ObservableObject {
    // MARK: - Private Properties
    private let model: RestourantCellModel
    private let restaurantId: String
    private let userLikesService: UserLikesService
    private var onAuthRequired: (() -> Void)?
    
    // MARK: - Published Properties
    @Published var isLiked: Bool
    @Published var isUpdatingLike: Bool = false
    
    // MARK: - Public Properties
    let isBookedByUser: Bool
    
    // MARK: - Initializer
    init(model: RestourantCellModel,
         restaurantId: String,
         initialIsLiked: Bool,
         isBooked: Bool,
         userLikesService: UserLikesService = UserLikesService(),
         onAuthRequired: (() -> Void)? = nil) {
        self.model = model
        self.restaurantId = restaurantId
        self.isLiked = initialIsLiked
        self.isBookedByUser = isBooked
        self.userLikesService = userLikesService
        self.onAuthRequired = onAuthRequired
    }
    
    // MARK: - Computed Properties
    var imageURL: String { model.imageURL }
    var title: String { model.title }
    var timeRange: String { model.timeRange }
    var likesCount: String { String(model.likesCount) }
    
    // MARK: - Like Action
    func toggleLike() {
        guard !isUpdatingLike else { return }
        
        isUpdatingLike = true
        let targetState = !isLiked
        
        Task {
            do {
                if targetState == true {
                    try await userLikesService.addLike(restaurantId: self.restaurantId)
                    print("RestourantCellVM: Successfully added like for \(self.restaurantId)")
                } else {
                    try await userLikesService.removeLike(restaurantId: self.restaurantId)
                    print("RestourantCellVM: Successfully removed like for \(self.restaurantId)")
                }
                await MainActor.run {
                     self.isLiked = targetState
                }
            } catch UserLikesServiceError.userNotAuthenticated {
                print("RestourantCellVM: Auth required for like action on \(self.restaurantId). Calling callback.")
                await MainActor.run {
                    self.onAuthRequired?()
                }
            } catch {
                print("❌ RestourantCellVM: Failed to update like status for \(self.restaurantId): \(error.localizedDescription)")
            }
            await MainActor.run {
                 self.isUpdatingLike = false
            }
        }
    }
} 
