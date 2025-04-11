import SwiftUI

// MARK: - StyledTextView
struct StyledTextView: View {
    // MARK: - Properties
    let text: String
    let fontStyle: FontStyles
    let fontSize: CGFloat

    // MARK: - Private Constants
    private let textColor: Color = .customRed
    private let strokeColor: Color = .white
    private let strokeWidth: CGFloat = 0.3
    private let shadowColor: Color = .customShadowColor
    private let shadowOffsetXFactor: CGFloat = -0.06
    private let shadowOffsetYFactor: CGFloat = 0.1

    // MARK: - Computed Properties
    private var calculatedShadowOffsetX: CGFloat {
        fontSize * shadowOffsetXFactor
    }
    private var calculatedShadowOffsetY: CGFloat {
        fontSize * shadowOffsetYFactor
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Text(text)
                .customFont(fontStyle, size: fontSize)
                .foregroundColor(shadowColor)
                .offset(x: calculatedShadowOffsetX, y: calculatedShadowOffsetY)

            Text(text)
                .customFont(fontStyle, size: fontSize)
                .foregroundColor(textColor)
                .textStroke(color: strokeColor, width: strokeWidth)
        }
    }
}

// MARK: - Preview
#Preview {
    VStack {
        StyledTextView(
            text: "Laconic Style",
            fontStyle: .customBold,
            fontSize: 50
        )
    }
    .padding()
    .background(Color.gray)
}
