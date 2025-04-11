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
        
        // MARK: - Life Cycle
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 3.5)) {
                    imageRevealFraction = 1.0
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}

