import SwiftUI

// MARK: - Font Names
enum FontStyles: String {
    case customExtraBold = "Barlow-ExtraBold"
    case customBold = "Barlow-Bold"
    case customSemiBold = "Barlow-SemiBold"
    case customRegular = "Barlow-Regular"
    
    func size(_ size: CGFloat) -> Font {
        return .custom(self.rawValue, size: size)
    }
}

// MARK: - Font Sizes
enum FontSizes {
    static let loading: CGFloat = 56
    static let title: CGFloat = 52
    static let form: CGFloat = 24
}

// MARK: - Sharp Text Stroke Modifier
struct SharpTextStrokeModifier: ViewModifier {
    let strokeColor: Color
    let strokeWidth: CGFloat

    func body(content: Content) -> some View {
        let shadowedContent = content
            .shadow(color: strokeColor, radius: 0, x: strokeWidth, y: strokeWidth)
            .shadow(color: strokeColor, radius: 0, x: -strokeWidth, y: -strokeWidth)
            .shadow(color: strokeColor, radius: 0, x: strokeWidth, y: -strokeWidth)
            .shadow(color: strokeColor, radius: 0, x: -strokeWidth, y: strokeWidth)

        return shadowedContent
            .shadow(color: strokeColor, radius: 0, x: 0, y: strokeWidth)
            .shadow(color: strokeColor, radius: 0, x: 0, y: -strokeWidth)
            .shadow(color: strokeColor, radius: 0, x: strokeWidth, y: 0)
            .shadow(color: strokeColor, radius: 0, x: -strokeWidth, y: 0)
    }
}

// MARK: - Extensions
extension Color {
    static let customRed = Color(red: 255/255, green: 51/255, blue: 51/255, opacity: 1)
    static let customWhite = Color(red: 241/255, green: 241/255, blue: 241/255, opacity: 1)
    static let customShadowColor = Color(red: 9/255, green: 16/255, blue: 42/255)
    static let customPlaceholderColor = Color(red: 140/255, green: 142/255, blue: 151/255)
}

extension Font {
    static func customFont(_ style: FontStyles, size: CGFloat) -> Font {
        return style.size(size)
    }
}

extension View {
    func customFont(_ style: FontStyles, size: CGFloat) -> some View {
        self.font(.customFont(style, size: size))
    }
}

extension View {
    func textStroke(color: Color, width: CGFloat = 0.3) -> some View {
        self.modifier(SharpTextStrokeModifier(strokeColor: color, strokeWidth: width))
    }
}


