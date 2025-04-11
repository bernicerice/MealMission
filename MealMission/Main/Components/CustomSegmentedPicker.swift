import SwiftUI

// MARK: - CustomSegmentedPicker
struct CustomSegmentedPicker<T: Identifiable & RawRepresentable & Equatable>: View where T.RawValue == String {
    // MARK: - Properties
    @Binding var selection: T
    let options: [T]
    
    let selectedTextColor: Color
    let indicatorColor: Color
    let fontStyle: FontStyles
    let fontSize: CGFloat
    
    // MARK: - Private Constants
    private let backgroundColor = Color(red: 44/255, green: 46/255, blue: 55/255)
    private let unselectedTextColor = Color.white
    private let heightRatio: CGFloat = 6 
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = width / heightRatio
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2)
                            .stroke(indicatorColor, lineWidth: 1)
                    )
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(indicatorColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2)
                            .stroke(indicatorColor, lineWidth: 1)
                    )
                    .frame(width: width / CGFloat(options.count))
                    .offset(x: getSelectedIndex() * (width / CGFloat(options.count)))
                    .animation(.bouncy(), value: selection)
                
                HStack(spacing: 0) {
                    ForEach(options) { option in
                        Button {
                            selection = option
                        } label: {
                            Text(option.rawValue)
                                .customFont(fontStyle, size: fontSize)
                                .foregroundColor(selection.id == option.id ? selectedTextColor : unselectedTextColor)
                                .frame(width: width / CGFloat(options.count))
                        }
                    }
                }
            }
            .frame(height: height)
        }
        .aspectRatio(heightRatio, contentMode: .fit)
    }
    
    // MARK: - Private Helper Methods
    private func getSelectedIndex() -> CGFloat {
        guard let index = options.firstIndex(where: { $0.id == selection.id }) else {
            return 0
        }
        return CGFloat(index)
    }
}

// MARK: - Preview
#Preview {
    enum PreviewMode: String, CaseIterable, Identifiable {
        case first = "First"
        case second = "Second"
        var id: String { self.rawValue }
    }
    
    struct PreviewWrapper: View {
        @State private var selectedMode: PreviewMode = .first
        
        var body: some View {
            CustomSegmentedPicker(
                selection: $selectedMode,
                options: PreviewMode.allCases,
                selectedTextColor: .black,
                indicatorColor: .yellow,
                fontStyle: .customSemiBold,
                fontSize: FontSizes.form
            )
            .padding()
            .background(Color.gray)
        }
    }
    
    return PreviewWrapper()
} 

