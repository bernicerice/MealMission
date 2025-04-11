import SwiftUI

// MARK: - TargetView
struct TargetView: View {
    // MARK: - State Objects & Properties
    @StateObject var viewModel: TargetViewModel
    @State private var selectedMode: TargetMode = .can
    
    // MARK: - Private Constants
    private let borderColor = Color(red: 148/255, green: 148/255, blue: 148/255, opacity: 1.0)
    private let searchBarHeight: CGFloat = 44
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                CustomSegmentedPicker(
                    selection: $selectedMode,
                    options: TargetMode.allCases,
                    selectedTextColor: .white,
                    indicatorColor: Color(red: 218/255, green: 5/255, blue: 5/255),
                    fontStyle: .customSemiBold,
                    fontSize: FontSizes.form
                )
                .padding(.horizontal)
                .padding(.top)

                HStack(spacing: 15) {
                    ZStack {
                        Capsule()
                            .fill(Color.customWhite)
                            .overlay(
                                Capsule().stroke(borderColor, lineWidth: 1)
                            )

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(borderColor)
                                .fontWeight(.semibold)

                            TextField("Search Restaurants...", text: $viewModel.searchText)
                        }
                        .padding(.horizontal, 12)
                    }
                    .frame(height: searchBarHeight)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Spacer()
                    Text("Error: \\(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                        .multilineTextAlignment(.center)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 15) {
                            ForEach(viewModel.filteredRestaurants) { restaurant in
                                RestourantCell(
                                    restaurant: restaurant,
                                    isInitiallyLiked: viewModel.likedRestaurantIDs.contains(restaurant.id),
                                    isBooked: viewModel.bookedRestaurantIDs.contains(restaurant.id),
                                    onAuthRequired: viewModel.requestAuthentication,
                                    onCellTapped: { selectedRestaurant in
                                        viewModel.selectedRestaurantForSheet = selectedRestaurant
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                }
            }

            // MARK: - Booking Sheet Overlay
            if let selectedRestaurant = viewModel.selectedRestaurantForSheet {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedRestaurantForSheet = nil 
                        }
                    }
                
                BookingSheetView(
                    restaurant: selectedRestaurant, 
                    mode: selectedMode,
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
        .task {
            await viewModel.loadInitialData()
        }
    }
}

// MARK: - Preview
struct TargetView_Previews: PreviewProvider {
    static var previews: some View {
        TargetView(viewModel: TargetViewModel(coordinator: nil))
            .background(Color.gray.opacity(0.7))
    }
} 
