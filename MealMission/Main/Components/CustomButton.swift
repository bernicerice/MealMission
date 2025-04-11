import SwiftUI

// MARK: - Primary Action Button (Gradient)

struct PrimaryActionButton: View {
    let title: String
    let action: () -> Void

    private let gradientColors: [Color] = [
        Color(red: 255/255, green: 75/255, blue: 75/255, opacity: 1),
        Color(red: 218/255, green: 5/255, blue: 5/255, opacity: 1)
    ]
    private let foregroundColor: Color = .white
    private let borderColor: Color = Color(red: 82/255, green: 0, blue: 0, opacity: 1)
    private let shadowColor = Color(red: 9/255, green: 16/255, blue: 42/255, opacity: 1)
    private let shadowOffset: CGFloat = 3

    var body: some View {
        BaseActionButton(
            title: title,
            fontStyle: .customSemiBold,
            foregroundColor: foregroundColor,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            hasBorder: true,
            borderColor: borderColor,
            hasGradient: true,
            gradientColors: gradientColors,
            action: action
        )
    }
}

// MARK: - Secondary Action Button (Solid Background)

struct SecondaryActionButton: View {
    let title: String
    let action: () -> Void

    private let backgroundColor: Color = Color(red: 36/255, green: 38/255, blue: 47/255, opacity: 1)
    private let foregroundColor: Color = .white
    private let borderColor: Color = .white
    private let shadowColor = Color(red: 9/255, green: 16/255, blue: 42/255, opacity: 1)
    private let shadowOffset: CGFloat = 3

    var body: some View {
        BaseActionButton(
            title: title,
            fontStyle: .customRegular,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            hasBorder: true,
            borderColor: borderColor,
            action: action
        )
    }
}

// MARK: - Base Action Button Logic (Internal)

fileprivate struct BaseActionButton: View {
    let title: String
    let fontStyle: FontStyles
    let foregroundColor: Color
    var backgroundColor: Color = .clear
    let shadowColor: Color
    let shadowOffset: CGFloat
    var hasBorder: Bool = false
    var borderColor: Color = .clear
    var hasGradient: Bool = false
    var gradientColors: [Color] = []
    let action: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = width / 5

            Button(action: action) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: height / 3)
                        .fill(shadowColor)
                        .frame(height: height)
                        .offset(y: shadowOffset)

                    ZStack {
                        if hasGradient && !gradientColors.isEmpty {
                            RadialGradient(
                                gradient: Gradient(colors: gradientColors),
                                center: .center,
                                startRadius: 0,
                                endRadius: width / 2
                            )
                            .clipShape(RoundedRectangle(cornerRadius: height / 3))
                        } else {
                            RoundedRectangle(cornerRadius: height / 3)
                                .fill(backgroundColor)
                        }

                        if hasBorder {
                            RoundedRectangle(cornerRadius: height / 3)
                                .stroke(borderColor, lineWidth: 1)
                        }

                        Text(title)
                            .customFont(fontStyle, size: FontSizes.form)
                            .foregroundColor(foregroundColor)
                    }
                    .frame(height: height)
                }
            }
            .frame(height: height + shadowOffset)
        }
        .frame(height: (UIScreen.main.bounds.width / 5) + shadowOffset) 
    }
}


// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PrimaryActionButton(
            title: "PRIMARY ACTION"
        ) {
            print("Primary Action Tapped")
        }

        SecondaryActionButton(
            title: "SECONDARY ACTION"
        ) {
            print("Secondary Action Tapped")
        }
    }
    .padding()
} 
