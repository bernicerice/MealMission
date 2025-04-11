import SwiftUI
import Combine
import FirebaseAuth

@MainActor

final class AuthorizationViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedMode: AuthMode = .login

    @Published var loginText: String = ""
    @Published var passwordText: String = ""
    @Published var nameText: String = ""
    @Published var emailText: String = ""
    @Published var confirmPasswordText: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Coordinator
    private weak var coordinator: MainCoordinator?

    // MARK: - Initializer
    init(coordinator: MainCoordinator? = nil) {
        self.coordinator = coordinator
    }

    // MARK: - Primary Action
    func primaryAction() {
        print("\(selectedMode == .login ? "Login" : "Registration") action triggered")
        errorMessage = nil
        isLoading = true

        let email = emailText
        let password = passwordText

        Task {
            do {
                if selectedMode == .login {
                    try await signIn(email: email, password: password)
                    print("Successfully signed in!")
                    await MainActor.run {
                         self.coordinator?.navigateToMainTabs()
                    }
                } else {
                    guard password == confirmPasswordText else {
                        await MainActor.run {
                             self.errorMessage = "Passwords do not match."
                             self.isLoading = false
                        }
                        return
                    }
                    try await signUp(email: email, password: password)
                    print("Successfully registered!")

                    await MainActor.run {
                         self.coordinator?.navigateToMainTabs()
                    }
                }
                await MainActor.run { self.isLoading = false }
            } catch {
                print("Authentication failed: \(error.localizedDescription)")
                await MainActor.run {
                    self.errorMessage = mapFirebaseError(error)
                    self.isLoading = false
                }
            }
        }
    }

    // MARK: - Private Authentication Methods
    private func signIn(email: String, password: String) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.emptyCredentials
        }
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    private func signUp(email: String, password: String) async throws {
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.emptyCredentials
        }
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }

    // MARK: - Error Handling
    private func mapFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        guard let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            return nsError.localizedDescription
        }
        
        switch errorCode {
        case .invalidEmail:
            return "Invalid email format."
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .weakPassword:
            return "Password is too weak. It should be at least 6 characters."
        case .wrongPassword:
            return "Incorrect password."
        case .userNotFound:
            return "No account found with this email."
        default:
            return nsError.localizedDescription
        }
    }
    
    // MARK: - Navigation
    func navigateToTabs() {
        coordinator?.navigateToMainTabs()
    }
}

// MARK: - AuthError Enum
enum AuthError: Error, LocalizedError {
    case emptyCredentials
    case passwordsDoNotMatch

    var errorDescription: String? {
        switch self {
        case .emptyCredentials:
            return "Email and password cannot be empty."
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        }
    }
} 
