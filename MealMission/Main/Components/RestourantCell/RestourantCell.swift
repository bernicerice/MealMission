import SwiftUI

// MARK: - RestourantCell View
struct RestourantCell: View {
    // MARK: - ObservedObject & Private Properties
    @ObservedObject private var viewModel: RestourantCellViewModel
    private let referenceWidth: CGFloat = 150
    private let gradient = Gradient(colors: [.black.opacity(0.7), .clear])
    
    // MARK: - Callbacks & Data
    private var onAuthRequired: () -> Void
    private var onCellTapped: (Restaurant) -> Void
    private let restaurant: Restaurant
    
    // MARK: - Initializer
    init(restaurant: Restaurant, isInitiallyLiked: Bool, isBooked: Bool, onAuthRequired: @escaping () -> Void, onCellTapped: @escaping (Restaurant) -> Void) {
        self.restaurant = restaurant
        self.onAuthRequired = onAuthRequired
        self.onCellTapped = onCellTapped
        let model = RestourantCellModel(from: restaurant)
        _viewModel = ObservedObject(wrappedValue: RestourantCellViewModel(model: model, 
                                                                    restaurantId: restaurant.id, 
                                                                    initialIsLiked: isInitiallyLiked,
                                                                    isBooked: isBooked,
                                                                    onAuthRequired: onAuthRequired))
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / referenceWidth
            let cornerRadius = 20 * scale
            
            ZStack {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: URL(string: viewModel.imageURL)) { phase in
                        if case .success(let image) = phase {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if case .failure = phase {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                        } else {
                            ProgressView()
                                .scaleEffect(scale)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

                    LinearGradient(gradient: gradient,
                                   startPoint: .bottom,
                                   endPoint: .center)

                    VStack(alignment: .center) {
                        Text(viewModel.title)
                            .customFont(.customSemiBold, size: 20 * scale)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text(viewModel.timeRange)
                            .customFont(.customRegular, size: 14 * scale)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 16 * scale)

                    HStack {
                        StyledTextView(text: viewModel.likesCount, fontStyle: .customRegular, fontSize: 18 * scale)
                        Spacer()
                        if viewModel.isUpdatingLike {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 20 * scale, height: 20 * scale)
                                .padding(.top, 10 * scale)
                        } else {
                            Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(.white)
                                .font(.system(size: 20 * scale))
                                .padding(.top, 10 * scale)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    print("Like button tapped for \(restaurant.name)")
                                    viewModel.toggleLike()
                                }
                        }
                    }
                    .padding(.horizontal, 10 * scale)
                    .padding(.vertical, 5 * scale)
                    .background(Color.black.opacity(0.8))
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                
                // MARK: - Booking Overlay
                if viewModel.isBookedByUser {
                    Color.green.opacity(0.4)
                        .allowsHitTesting(false)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.4)
                        .foregroundColor(.gray.opacity(0.7))
                        .allowsHitTesting(false)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .contentShape(Rectangle())
            .onTapGesture {
                print("RestourantCell background tapped for: \(restaurant.name)")
                onCellTapped(restaurant)
            }
        }
        .aspectRatio(3/4, contentMode: .fit)
    }
}

// MARK: - Preview
#Preview {
    let mockRestaurant = Restaurant(id: "prev1", name: "Preview Place", timeRange: "10-22", likesCount: 123, imageURL: "https://via.placeholder.com/150x200")
    RestourantCell(
        restaurant: mockRestaurant, 
        isInitiallyLiked: false, 
        isBooked: true, 
        onAuthRequired: { print("Auth Required") }, 
        onCellTapped: { r in print("Cell Tapped: \(r.name)") }
    )
    .frame(width: 150, height: 200)
} 
