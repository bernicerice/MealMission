import SwiftUI

// MARK: - TabItem Enum
enum TabItem: Int, CaseIterable, Identifiable {
    case table
    case liked
    case account
    
    var id: Int { self.rawValue }
    
    // MARK: - Computed Properties
    var iconName: String {
        switch self {
        case .table: return "table"
        case .liked: return "likes"
        case .account: return "account"
        }
    }
    
    // MARK: - View Builder
    @MainActor
    @ViewBuilder
    func view(coordinator: MainCoordinator) -> some View {
        switch self {
        case .table:
            let targetViewModel = TargetViewModel(coordinator: coordinator)
            TargetView(viewModel: targetViewModel)
        case .liked:
            let likedViewModel = LikedViewModel(coordinator: coordinator)
            LikedView(viewModel: likedViewModel)
        case .account:
            let profileViewModel = ProfileViewModel(coordinator: coordinator)
            ProfileView(viewModel: profileViewModel)
        }
    }
} 
