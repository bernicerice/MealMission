import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var profileImage: Image? = nil
    @Published var displayName: String = "Loading..."
    @Published var email: String = "Loading..."
    @Published var isUserLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var deletionError: String? = nil

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let imageFileName = "profileImage.jpg"
    
    private weak var coordinator: MainCoordinator?

    // MARK: - Initializer
    init(coordinator: MainCoordinator? = nil) {
        self.coordinator = coordinator
        loadUserData()
        loadImage()
    }

    // MARK: - User Data Management
    func loadUserData() {
        if let user = Auth.auth().currentUser {
             isUserLoggedIn = true
             displayName = user.displayName ?? "No Name"
             email = user.email ?? "No Email Provided"
             if displayName == "No Name" && !email.isEmpty && email != "No Email Provided" {
                  displayName = String(email.split(separator: "@").first ?? "User")
             }
        } else {
            isUserLoggedIn = false
            displayName = "Anonymous"
            email = "-"
            deletionError = nil 
            isLoading = false
        }
    }

    // MARK: - Authentication Actions
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            deletionError = "No user logged in to delete."
            return
        }

        isLoading = true
        deletionError = nil

        Task {
            do {
                try await user.delete()
                print("User account deleted successfully.")
            } catch let error as NSError {
                print("Error deleting user account: \(error.localizedDescription)")
                if let errorCode = AuthErrorCode(rawValue: error.code),
                   errorCode == .requiresRecentLogin {
                    deletionError = "Please log out and log back in to delete your account."
                } else {
                    deletionError = "Failed to delete account: \(error.localizedDescription)"
                }
                isLoading = false
            }
        }
    }

    // MARK: - Image Management
    func updateImage(from data: Data) {
        if let uiImage = UIImage(data: data) {
            profileImage = Image(uiImage: uiImage)
            saveImageLocally(uiImage: uiImage)
        }
    }

    func loadImage() {
        if let uiImage = loadImageFromDisk() {
            profileImage = Image(uiImage: uiImage)
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func saveImageLocally(uiImage: UIImage) {
        guard let data = uiImage.jpegData(compressionQuality: 0.8) else { return }
        let url = getDocumentsDirectory().appendingPathComponent(imageFileName)
        try? data.write(to: url)
        print("Image saved locally to \(url.path)")
    }

    private func loadImageFromDisk() -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(imageFileName)
        if let data = try? Data(contentsOf: url) {
            print("Image loaded from disk.")
            return UIImage(data: data)
        }
        print("No image found on disk.")
        return nil
    }
    
    // MARK: - Navigation
    func navigateToAuthorization() {
        coordinator?.navigate(to: .authorizationScreen)
    }
} 
