import SwiftUI
import FirebaseAuth

// MARK: - Screens Enum
enum Screens {
//    case launchScreen
    case authorizationScreen
    case mainTabs
}

// MARK: - MainCoordinator Class
class MainCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published var currentScreen: Screens = .authorizationScreen
    
    // MARK: - Private Properties
    private var authHandle: AuthStateDidChangeListenerHandle?

    // MARK: - Initializer & Deinitializer
    init() {
        currentScreen = .authorizationScreen
        addAuthStateListener()
    }

    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
            print("Auth state listener removed.")
        }
    }
    
    // MARK: - Navigation Methods
    func navigate(to screen: Screens) {
        if currentScreen != screen {
            currentScreen = screen
        }
    }
    
    func handleLaunchScreenCompletion() {
//        if currentScreen == .launchScreen {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                withAnimation {
                    if Auth.auth().currentUser == nil {
                        self.navigate(to: .authorizationScreen)
                    } else {
                        self.navigate(to: .mainTabs)
                    }
                }
            }
//        }
    }
    
    func navigateToMainTabs() {
        withAnimation {
            navigate(to: .mainTabs)
        }
    }
    
    // MARK: - Auth State Handling
    private func addAuthStateListener() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            print("Auth state changed. User: \(user?.uid ?? "nil")")
            DispatchQueue.main.async {
                withAnimation {
                    if user != nil && self.currentScreen == .authorizationScreen { 
                        print("Auth listener: User logged in from auth screen, navigating to main tabs.")
                        self.navigate(to: .mainTabs)
                    } else if user == nil && self.currentScreen == .mainTabs {
                        print("Auth listener: User logged out from main tabs, navigating to authorization.")
                        self.navigate(to: .authorizationScreen)
//                    } else if user == nil && self.currentScreen == .launchScreen {
//                        print("Auth listener: User not logged in on launch, waiting for launch completion.")
//                    } else if user != nil && self.currentScreen == .launchScreen {
//                        print("Auth listener: User already logged in on launch, waiting for launch completion.")
                    }
                }
            }
        }
    }
}

// MARK: - MainCoordinatorView Struct
struct MainCoordinatorView: View {
    // MARK: - StateObject
    @StateObject private var coordinator = MainCoordinator()
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                switch coordinator.currentScreen {
//                case .launchScreen:
//                    LaunchScreenView()
//                        .onAppear {
//                            coordinator.handleLaunchScreenCompletion()
//                        }
                case .authorizationScreen:
                    AuthorizationView(coordinator: coordinator)
                case .mainTabs:
                    TabBarContainerView(coordinator: coordinator)
                }
            }
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RadialGradient(
                        gradient: Gradient(colors: [Color(red: 69/255, green: 71/255, blue: 82/255), Color(red: 36/255, green: 38/255, blue: 47/255)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: UIScreen.main.bounds.height / 2
                    )
                    Image("background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
                .ignoresSafeArea()
            )
            .onAppear {
                coordinator.handleLaunchScreenCompletion()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainCoordinatorView()
}

