import SwiftUI

// MARK: - LikedView
struct LikedView: View {
    // MARK: - State Objects & Properties
    @StateObject var viewModel: LikedViewModel
    @State private var isVisible: Bool = false

    // MARK: - Private Constants
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 20) {
                StyledTextView(
                    text: "Liked",
                    fontStyle: .customExtraBold,
                    fontSize: FontSizes.title
                )

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                    Spacer()
                } else if viewModel.likedRestaurants.isEmpty {
                     Spacer()
                     Text("You haven't liked any restaurants yet.")
                         .foregroundColor(.secondary)
                         .padding()
                     Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(viewModel.likedRestaurants) { restaurant in
                                RestourantCell(
                                    restaurant: restaurant,
                                    isInitiallyLiked: true,
                                    isBooked: viewModel.bookedRestaurantIDs.contains(restaurant.id),
                                    onAuthRequired: viewModel.requestAuthentication,
                                    onCellTapped: { selectedRestaurant in
                                        viewModel.selectedRestaurantForSheet = selectedRestaurant
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            }
            .padding(.top)

            // MARK: - Booking Sheet Overlay
            if let selectedRestaurant = viewModel.selectedRestaurantForSheet {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture { viewModel.selectedRestaurantForSheet = nil }
                
                BookingSheetView(
                    restaurant: selectedRestaurant, 
                    mode: .can, 
                    onDismiss: { 
                        withAnimation {
                            viewModel.selectedRestaurantForSheet = nil 
                        }
                    },
                    onBookingSuccess: { bookedRestaurantId in
                        Task {
                            await viewModel.markRestaurantAsBooked(restaurantId: bookedRestaurantId)
                        }
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        // MARK: - View Lifecycle
        .task {
            await viewModel.loadLikedRestaurants()
        }
    }
}

// MARK: - Preview
#Preview {
    LikedView(viewModel: LikedViewModel(coordinator: nil))
        .background(Color.gray.opacity(0.7))
}
