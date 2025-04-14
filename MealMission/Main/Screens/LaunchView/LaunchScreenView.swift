import SwiftUI

struct LaunchScreenView: View {
    @State private var imageRevealFraction: CGFloat = 0.0
    
    // MARK: - Body
    var body: some View {
        VStack {
            ZStack {
                ZStack {
                    Image("mask")
                        .shadow(color: Color(red: 1.0, green: 170/255, blue: 170/255, opacity: 0.25), radius: 10)
                    Image("mask")
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                
                Image("mask")
                    .mask {
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color.white)
                                .frame(height: geometry.size.height * imageRevealFraction)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        }
                    }
            }
            
            Text("Loading...")
                .customFont(.customBold, size: FontSizes.loading)
                .foregroundColor(.white)
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
        // MARK: - Life Cycle
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 8)) {
                    imageRevealFraction = 1.0
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}

