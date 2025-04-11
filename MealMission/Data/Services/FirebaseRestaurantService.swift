import Foundation
import FirebaseDatabase

// MARK: - RestaurantServiceError Enum
enum RestaurantServiceError: Error, LocalizedError {
    case dataNotFound
    case decodingError(Error)
    case firebaseError(Error)
    case unknownError
    case invalidDataStructure

    var errorDescription: String? {
        switch self {
        case .dataNotFound:
            return "Could not find restaurant data in the database."
        case .decodingError(let underlyingError):
            return "Failed to decode restaurant data: \(underlyingError.localizedDescription)"
        case .firebaseError(let underlyingError):
            return "An error occurred while fetching data from Firebase: \(underlyingError.localizedDescription)"
        case .unknownError:
            return "An unknown error occurred."
        case .invalidDataStructure:
            return "Data at the specified path is not in the expected structure."
        }
    }
}

// MARK: - Private FirebaseRestaurantData Struct
private struct FirebaseRestaurantData: Decodable {
    let name: String
    let timeRange: String
    let likesCount: Int
    let imageURL: String
}

// MARK: - FirebaseRestaurantService Class
final class FirebaseRestaurantService {

    // MARK: - Private Properties
    private let databaseRef = Database.database().reference()

    // MARK: - Public Methods
    func fetchRestaurants() async throws -> [Restaurant] {
        let restaurantsNodeRef = databaseRef.child("restaurants")

        do {
            let snapshot = try await restaurantsNodeRef.getData()

            guard snapshot.exists(), let dataDict = snapshot.value as? [String: Any] else {
                print("Data not found or not in expected format at path: \(restaurantsNodeRef.url)")
                throw RestaurantServiceError.dataNotFound
            }

            var restaurants: [Restaurant] = []

            for (key, value) in dataDict {
                do {
                    let restaurantData = try JSONSerialization.data(withJSONObject: value)
                    let decodedData = try JSONDecoder().decode(FirebaseRestaurantData.self, from: restaurantData)

                    let finalRestaurant = Restaurant(
                        id: key,
                        name: decodedData.name,
                        timeRange: decodedData.timeRange,
                        likesCount: decodedData.likesCount,
                        imageURL: decodedData.imageURL
                    )
                    restaurants.append(finalRestaurant)

                } catch let decodingError {
                    print("⚠️ Failed to decode restaurant with ID '\(key)'. Error: \(decodingError.localizedDescription). Raw value: \(value)")
                }
            }

            return restaurants

        } catch let error where error is RestaurantServiceError {
            throw error
        } catch let error {
            print("❌ Firebase error fetching restaurants: \(error.localizedDescription)")
            throw RestaurantServiceError.firebaseError(error)
        }
    }
} 