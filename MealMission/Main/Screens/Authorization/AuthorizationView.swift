import SwiftUI
import FirebaseAuth

// MARK: - AuthMode Enum
enum AuthMode: String, CaseIterable, Identifiable {
    case login = "Log in"
    case registration = "Registration"
    var id: String { self.rawValue }
}

// MARK: - AuthorizationView
struct AuthorizationView: View {
    // MARK: - StateObject & ObservedObject
    @StateObject private var viewModel: AuthorizationViewModel
    @ObservedObject var coordinator: MainCoordinator

    // MARK: - Initializer
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: AuthorizationViewModel(coordinator: coordinator))
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            VStack {
                StyledTextView(
                    text: "Start your way",
                    fontStyle: .customBold,
                    fontSize: FontSizes.title
                )

                CustomSegmentedPicker(
                    selection: $viewModel.selectedMode,
                    options: AuthMode.allCases,
                    selectedTextColor: Color(red: 44/255, green: 46/255, blue: 55/255),
                    indicatorColor: .white,
                    fontStyle: .customSemiBold,
                    fontSize: FontSizes.form
                )
                .padding(.horizontal)
                .padding(.bottom, 10)

                LoginFormView(viewModel: viewModel)
                .padding(.horizontal)

                Spacer()
            }
            if viewModel.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.0)
            }
        }
    }
}

// MARK: - LoginFormView
struct LoginFormView: View {
    // MARK: - ObservedObject
    @ObservedObject var viewModel: AuthorizationViewModel
    
    // MARK: - Private Constants
    private let backgroundColor = Color(red: 241/255, green: 241/255, blue: 241/255, opacity: 1)
    private let borderColor = Color(red: 148/255, green: 148/255, blue: 148/255, opacity: 1)
    private let textColor = Color.customPlaceholderColor
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .customFont(.customRegular, size: FontSizes.form)
                    .padding(.bottom, 5)
                    .transition(.opacity)
            }
            
            ZStack {
                if viewModel.selectedMode == .login {
                    VStack(spacing: 1) {
                        CustomTextField(text: $viewModel.emailText, placeholder: "Email")
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        CustomTextField(text: $viewModel.passwordText, placeholder: "Password", isSecure: true)
                            .textContentType(.password)
                    }
                } else {
                    VStack(spacing: 0) {
                        CustomTextField(text: $viewModel.nameText, placeholder: "Name")
                            .textContentType(.name)
                        CustomTextField(text: $viewModel.emailText, placeholder: "Email")
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        CustomTextField(text: $viewModel.passwordText, placeholder: "Password", isSecure: true)
                            .textContentType(.newPassword)
                        CustomTextField(text: $viewModel.confirmPasswordText, placeholder: "Confirm password", isSecure: true)
                            .textContentType(.newPassword)
                    }
                }
            }
            
            VStack(spacing: 5) {
                PrimaryActionButton(
                    title: viewModel.selectedMode == .login ? "LOG IN" : "REGISTRATION"
                ) {
                    if !viewModel.isLoading {
                        viewModel.primaryAction()
                    }
                }
                .disabled(viewModel.isLoading)
                .opacity(viewModel.isLoading ? 0.5 : 1.0)
                
                Text("or")
                    .customFont(.customRegular, size: FontSizes.form)
                    .foregroundColor(.white)
                
                SecondaryActionButton(
                    title: "ANONIMOUS"
                ) {
                    viewModel.navigateToTabs()
                }
            }
            .padding(.top)
        }
        .animation(.default, value: viewModel.selectedMode)
        .animation(.easeInOut, value: viewModel.errorMessage)
    }
}

// MARK: - CustomTextField
struct CustomTextField: View {
    // MARK: - Properties
    @Binding var text: String
    let placeholder: String
    var isSecure: Bool = false
    
    // MARK: - Private Constants
    private let backgroundColor = Color(red: 241/255, green: 241/255, blue: 241/255, opacity: 1)
    private let borderColor = Color(red: 148/255, green: 148/255, blue: 148/255, opacity: 1)
    private let textColor = Color.customPlaceholderColor
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = width / 6
            
            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(textColor)
                                .customFont(.customRegular, size: FontSizes.form)
                        }
                } else {
                    TextField("", text: $text)
                        .placeholder(when: text.isEmpty) {
                            Text(placeholder)
                                .foregroundColor(textColor)
                                .customFont(.customRegular, size: FontSizes.form)
                        }
                }
            }
            .customFont(.customRegular, size: FontSizes.form)
            .padding(.horizontal)
            .frame(height: height)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: height / 2))
        }
        .frame(height: UIScreen.main.bounds.width / 6)
    }
}

// MARK: - View Extension (Placeholder)
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Preview
#Preview {
    AuthorizationView(coordinator: MainCoordinator())
}

