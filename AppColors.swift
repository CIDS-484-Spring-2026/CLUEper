import SwiftUI

enum AppColors {
    static let accentRed = Color.red
    static let appBackground = Color.black
    static let cardBackground = Color.white.opacity(0.06)
    static let cardBackgroundStrong = Color.white.opacity(0.1)
    static let cardBorder = Color.white.opacity(0.12)
    static let mutedText = Color.white.opacity(0.62)
    static let subduedText = Color.white.opacity(0.42)
    static let overlay = Color.black.opacity(0.45)
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension View {
    func appCardStyle(cornerRadius: CGFloat = 18) -> some View {
        self
            .background(AppColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
            .cornerRadius(cornerRadius)
    }
}
