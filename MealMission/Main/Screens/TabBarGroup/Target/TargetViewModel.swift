import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

// MARK: - Main Actor
@MainActor
class TargetViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var restaurants: [Restaurant] = []
    @Published var likedRestaurantIDs: Set<String> = []
    @Published var bookedRestaurantIDs: Set<String> = [] 
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedRestaurantForSheet: Restaurant? = nil
    @Published var searchText: String = ""

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
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        print("TargetViewModel: Starting to load initial data...")

        async let restaurantsTask = restaurantService.fetchRestaurants()
        async let likedIDsTask = userLikesService.fetchLikedRestaurantIDs()
        async let bookedIDsTask = fetchBookedRestaurantIDs()
        
        do {
            let fetchedRestaurants = try await restaurantsTask
            let fetchedLikedIDs = try await likedIDsTask
            let fetchedBookedIDs = await bookedIDsTask
            
            let sortedRestaurants = fetchedRestaurants.sorted { $0.likesCount > $1.likesCount }
            
            self.restaurants = sortedRestaurants
            self.likedRestaurantIDs = fetchedLikedIDs
            self.bookedRestaurantIDs = fetchedBookedIDs
            print("TargetViewModel: Successfully loaded and sorted \(sortedRestaurants.count) restaurants, \(fetchedLikedIDs.count) liked IDs, and \(fetchedBookedIDs.count) booked IDs.")
            
        } catch let error as RestaurantServiceError {
            print("TargetViewModel: Error loading initial data (Restaurant Service Error): \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
        } catch let error as UserLikesServiceError {
             print("TargetViewModel: Error loading initial data (User Likes Service Error): \(error.localizedDescription)")
             self.errorMessage = error.localizedDescription 
        } catch {
            print("TargetViewModel: Error loading initial data (Unknown Error): \(error.localizedDescription)")
            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        isLoading = false
    }

    // MARK: - Navigation
    func requestAuthentication() {
        print("TargetViewModel: Authentication required, navigating to Auth screen...")
        coordinator?.navigate(to: .authorizationScreen)
    }

    // MARK: - Computed Properties
    var filteredRestaurants: [Restaurant] {
        guard !searchText.isEmpty else {
            return restaurants
        }
        return restaurants.filter { restaurant in
            restaurant.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Public Interface
    
    func markRestaurantAsBooked(restaurantId: String) async {
        await MainActor.run {
            if !bookedRestaurantIDs.contains(restaurantId) {
                bookedRestaurantIDs.insert(restaurantId)
                print("TargetViewModel: Marked restaurant \(restaurantId) as booked on MainActor.")
            }
        }
    }

    // MARK: - Private Helper Functions
    
    private func fetchBookedRestaurantIDs() async -> Set<String> {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("TargetViewModel: Cannot fetch bookings, user not logged in.")
            return []
        }
        
        let dbRef = Database.database().reference().child("bookings").child(userId)
        var bookedIDs = Set<String>()
        
        do {
            print("TargetViewModel: Fetching booked restaurant IDs for user: \(userId)")
            let snapshot = try await dbRef.getData()
            
            guard let bookingsDict = snapshot.value as? [String: Any] else {
                print("TargetViewModel: No bookings found for user or data is not a dictionary.")
                return []
            }
            
            for (_, bookingInfo) in bookingsDict {
                if let bookingDetails = bookingInfo as? [String: Any], let restaurantId = bookingDetails["restaurantId"] as? String {
                    bookedIDs.insert(restaurantId)
                }
            }
            print("TargetViewModel: Successfully fetched \(bookedIDs.count) booked restaurant IDs.")
        } catch {
            print("TargetViewModel: Error fetching booked restaurant IDs: \(error.localizedDescription)")
        }
        
        return bookedIDs
    }
} 
