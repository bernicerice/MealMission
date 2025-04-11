import SwiftUI

// MARK: - TabBarContainerView
struct TabBarContainerView: View {
    
    // MARK: - Coordinator & State
    @ObservedObject var coordinator: MainCoordinator
    @State private var selectedTab: TabItem = .table

    // MARK: - Initializer
    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            selectedTab.view(coordinator: coordinator)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - CustomTabBar
struct CustomTabBar: View {
    
    // MARK: - Properties
    @Binding var selectedTab: TabItem
    private let selectedColor = Color(red: 36/255, green: 38/255, blue: 47/255)
    private let deselectedColor = Color.white
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .overlay(
                    Color(red: 36/255, green: 38/255, blue: 47/255).opacity(0.6)
                )
                .clipShape(Capsule())
            
            GeometryReader { geometry in
                let tabWidth = geometry.size.width / CGFloat(TabItem.allCases.count)
                
                Capsule()
                    .fill(Color.white)
                    .frame(width: tabWidth, height: 70)
                    .offset(x: calculateIndicatorOffset(tabWidth: tabWidth))
                    .animation(.bouncy, value: selectedTab)

                HStack {
                    ForEach(TabItem.allCases) { tab in
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            Image(tab.iconName)
                                .resizable()
                                .renderingMode(.template)
                                .scaledToFit()
                                .frame(width: 35, height: 35)
                                .foregroundColor(selectedTab == tab ? selectedColor : deselectedColor)
                        }
                        Spacer()
                    }
                }
                .frame(height: 70)
            }
        }
        .frame(height: 70)
        .shadow(radius: 5)
        .padding(.horizontal, 15)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // MARK: - Private Helper Methods
    private func calculateIndicatorOffset(tabWidth: CGFloat) -> CGFloat {
        guard let index = TabItem.allCases.firstIndex(where: { $0 == selectedTab }) else {
            return 0
        }
        return CGFloat(index) * tabWidth
    }
    
    private var safeAreaInsets: UIEdgeInsets {
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
            .windows.first?.safeAreaInsets ?? .zero
    }
}

// MARK: - View Extension (Corner Radius)
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - RoundedCorner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#Preview {
    TabBarContainerView(coordinator: MainCoordinator())
} 
