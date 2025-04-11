import SwiftUI
import PhotosUI // Import PhotosUI for photo picker functionality

// MARK: - ProfileView
struct ProfileView: View {
    // MARK: - StateObject & State Variables
    @StateObject var viewModel: ProfileViewModel 
    
    @State private var showingImagePicker = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isVisible: Bool = false
    
    // MARK: - Initializer
    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        ZStack { 
            VStack(spacing: 5) {
                StyledTextView(
                    text: "Profile",
                    fontStyle: .customExtraBold,
                    fontSize: FontSizes.title
                )
                .opacity(isVisible ? 1 : 0)

                // MARK: - Avatar Image Section
                ZStack {
                    Group {
                        if let image = viewModel.profileImage {
                            image
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image("avatar") 
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(width: 180, height: 180) 
                    .clipShape(RoundedRectangle(cornerRadius: 25)) 
                    .overlay(
                        RoundedRectangle(cornerRadius: 25).fill(Color.black.opacity(0.5))
                    )
                    .overlay(
                        Text("Choose \nimage")
                            .customFont(.customSemiBold, size: 18) 
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    )
                    .onTapGesture {
                        showingImagePicker = true
                    }
                }

                // MARK: - User Info
                Text(viewModel.displayName)
                    .customFont(.customSemiBold, size: 34) 
                    .foregroundColor(.white)
                    .padding(.bottom, 5) 
                
                VStack(alignment: .leading, spacing: 0) { 
                    Text("Email:")
                        .customFont(.customRegular, size: 18) 
                        .foregroundColor(.customWhite) 
                    
                    Text(viewModel.email)
                        .customFont(.customSemiBold, size: 24)
                        .foregroundColor(.white)
                        .tint(.white) 
                }
                .padding(.horizontal) 
                .frame(maxWidth: .infinity, alignment: .leading) 
                
                Spacer() 

                // MARK: - Error Message
                if let error = viewModel.deletionError {
                    Text(error)
                        .foregroundColor(.red)
                        .customFont(.customRegular, size: FontSizes.form)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.deletionError)
                }

                // MARK: - Action Buttons
                VStack(spacing: 10) {
                    SecondaryActionButton(title: viewModel.isUserLoggedIn ? "LOG OUT" : "AUTHORIZATION") { 
                        if viewModel.isUserLoggedIn {
                            viewModel.signOut()
                        } else {
                            viewModel.navigateToAuthorization()
                        }
                    }
                    .disabled(viewModel.isLoading) 
                    
                    if viewModel.isUserLoggedIn {
                        PrimaryActionButton(title: "DELETE ACCOUNT") { 
                            viewModel.deleteAccount()
                        }
                        .disabled(viewModel.isLoading) 
                        .opacity(viewModel.isLoading ? 0.5 : 1.0)
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 70)
                .animation(.default, value: viewModel.isUserLoggedIn)

            }
            .padding(.top)
            // MARK: - View Lifecycle & Modifiers
            .onAppear {
                viewModel.loadUserData()
                viewModel.loadImage()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) { 
                        isVisible = true
                    }
                }
            }
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedItem,
                matching: .images, 
                photoLibrary: .shared() 
            )
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        viewModel.updateImage(from: data)
                    }
                }
            }
            
            // MARK: - Loading Overlay
            if viewModel.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2.0)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    let previewCoordinator = MainCoordinator()
    let previewViewModel = ProfileViewModel(coordinator: previewCoordinator)
    
    return ZStack {
        RadialGradient(
            gradient: Gradient(colors: [Color(red: 69/255, green: 71/255, blue: 82/255), Color(red: 36/255, green: 38/255, blue: 47/255)]),
            center: .center,
            startRadius: 0,
            endRadius: UIScreen.main.bounds.height / 2
        ).ignoresSafeArea()
        
        ProfileView(viewModel: previewViewModel)
    }
}
