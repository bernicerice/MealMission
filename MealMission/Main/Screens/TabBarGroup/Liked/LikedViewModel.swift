import SwiftUI
import Combine
import FirebaseAuth
import FirebaseDatabase

@MainActor
class LikedViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var likedRestaurants: [Restaurant] = []
    @Published var bookedRestaurantIDs: Set<String> = []
    @Published var selectedRestaurantForSheet: Restaurant? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Services & Coordinator
    private let restaurantService: FirebaseRestaurantService
    private let userLikesService: UserLikesService
    private weak var coordinator: MainCoordinator?

    // MARK: - Initializer
    init(restaurantService: FirebaseRestaurantService = FirebaseRestaurantService(),
         userLikesService: UserLikesService = UserLikesService(),
         coordinator: MainCoordinator?) {
        self.restaurantService = restaurantService
        self.userLikesService = userLikesService
        self.coordinator = coordinator
    }
    
    // MARK: - Data Loading
    func loadLikedRestaurants() async {
        isLoading = true
        errorMessage = nil
        print("LikedViewModel: Starting to load liked restaurants...")

        async let restaurantsTask = restaurantService.fetchRestaurants()
        async let likedIDsTask = userLikesService.fetchLikedRestaurantIDs()
        async let bookedIDsTask = fetchBookedRestaurantIDs()

        do {
            let allRestaurants = try await restaurantsTask
            let likedIDs = try await likedIDsTask
            let bookedIDs = await bookedIDsTask
            
            let filteredRestaurants = allRestaurants.filter { likedIDs.contains($0.id) }
            
            self.likedRestaurants = filteredRestaurants
            self.bookedRestaurantIDs = bookedIDs
            print("LikedViewModel: Successfully loaded and filtered \(filteredRestaurants.count) liked restaurants and fetched \(bookedIDs.count) booked IDs.")
            
        } catch let error as RestaurantServiceError {
            print("LikedViewModel: Error loading liked data (Restaurant Service Error): \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        } catch let error as UserLikesServiceError {
            print("LikedViewModel: Error loading liked data (User Likes Service Error): \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription 
        } catch {
            print("LikedViewModel: Error loading liked data (Unknown Error): \(error.localizedDescription)")
            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

    // MARK: - Navigation
    func requestAuthentication() {
        print("LikedViewModel: Authentication possibly required (e.g., for unlike), navigating to Auth screen...")
        coordinator?.navigate(to: .authorizationScreen)
    }

    // MARK: - Public Interface
    func markRestaurantAsBooked(restaurantId: String) async {
        await MainActor.run {
            if !bookedRestaurantIDs.contains(restaurantId) {
                bookedRestaurantIDs.insert(restaurantId)
                print("LikedViewModel: Marked restaurant \(restaurantId) as booked on MainActor.")
            }
        }
    }

    // MARK: - Private Helper Functions
    private func fetchBookedRestaurantIDs() async -> Set<String> {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("LikedViewModel: Cannot fetch bookings, user not logged in.")
            return []
        }
        
        let dbRef = Database.database().reference().child("bookings").child(userId)
        var bookedIDs = Set<String>()
        
        do {
            print("LikedViewModel: Fetching booked restaurant IDs for user: \(userId)")
            let snapshot = try await dbRef.getData()
            
            guard let bookingsDict = snapshot.value as? [String: Any] else {
                print("LikedViewModel: No bookings found for user or data is not a dictionary.")
                return []
            }
            
            for (_, bookingInfo) in bookingsDict {
                if let bookingDetails = bookingInfo as? [String: Any], let restaurantId = bookingDetails["restaurantId"] as? String {
                    bookedIDs.insert(restaurantId)
                }
            }
            print("LikedViewModel: Successfully fetched \(bookedIDs.count) booked restaurant IDs.")
        } catch {
            print("LikedViewModel: Error fetching booked restaurant IDs: \(error.localizedDescription)")
        }
        
        return bookedIDs
    }
}