import Foundation
import FirebaseAuth
import FirebaseDatabase

// MARK: - UserLikesServiceError Enum
enum UserLikesServiceError: Error, LocalizedError {
    case userNotAuthenticated
    case firebaseError(Error)
    case failedToGetUserID
    case dataParsingError
    case unknownError

    var errorDescription: String? {
        switch self {
        case .userNotAuthenticated:
            return "User is not currently authenticated."
        case .firebaseError(let underlyingError):
            return "A Firebase error occurred: \(underlyingError.localizedDescription)"
        case .failedToGetUserID:
            return "Failed to retrieve the current user ID."
        case .dataParsingError:
            return "Failed to parse the liked restaurants data."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

// MARK: - UserLikesService Class
final class UserLikesService {

    // MARK: - Private Properties
    private let databaseRef = Database.database().reference()

    // MARK: - Private Helper Methods
    private func getCurrentUserID() throws -> String {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw UserLikesServiceError.userNotAuthenticated
        }
        return userID
    }

    // MARK: - Public Methods
    func fetchLikedRestaurantIDs() async throws -> Set<String> {
        print("UserLikesService: Fetching liked restaurant IDs...")
        let userID: String
        do {
            userID = try getCurrentUserID()
        } catch {
            print("UserLikesService: User not authenticated, returning empty set.")
            return Set<String>()
        }

        let userLikesRef = databaseRef.child("user_likes").child(userID)

        do {
            let snapshot = try await userLikesRef.getData()

            guard snapshot.exists(), let dataDict = snapshot.value as? [String: Bool] else {
                print("UserLikesService: No likes data found for user \(userID), returning empty set.")
                return Set<String>()
            }

            let likedIDs = Set(dataDict.keys)
            print("UserLikesService: Found \(likedIDs.count) liked IDs for user \(userID).")
            return likedIDs

        } catch let error {
            print("❌ UserLikesService: Firebase error fetching likes for user \(userID): \(error.localizedDescription)")
            throw UserLikesServiceError.firebaseError(error)
        }
    }

    func addLike(restaurantId: String) async throws {
        print("UserLikesService: Adding like for restaurant \(restaurantId)...")
        let userID = try getCurrentUserID()
        
        let likeRef = databaseRef.child("user_likes").child(userID).child(restaurantId)
        
        do {
            try await likeRef.setValue(true)
            print("UserLikesService: Successfully added like for restaurant \(restaurantId) by user \(userID).")
        } catch let error {
            print("❌ UserLikesService: Firebase error adding like for restaurant \(restaurantId) by user \(userID): \(error.localizedDescription)")
            throw UserLikesServiceError.firebaseError(error)
        }
    }

    func removeLike(restaurantId: String) async throws {
        print("UserLikesService: Removing like for restaurant \(restaurantId)...")
        let userID = try getCurrentUserID()

        let likeRef = databaseRef.child("user_likes").child(userID).child(restaurantId)

        do {
            try await likeRef.removeValue()
            print("UserLikesService: Successfully removed like for restaurant \(restaurantId) by user \(userID).")
        } catch let error {
            print("❌ UserLikesService: Firebase error removing like for restaurant \(restaurantId) by user \(userID): \(error.localizedDescription)")
            throw UserLikesServiceError.firebaseError(error)
        }
    }
} 