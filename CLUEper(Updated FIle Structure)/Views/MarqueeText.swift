import SwiftUI

/// Horizontally scrolling text (ticker/marquee effect)
struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double   // pixels per second

    @State private var textWidth: CGFloat = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            Text(text)
                .font(font)
                .foregroundColor(.white.opacity(0.7))
                .background(
                    GeometryReader { textGeo in
                        Color.clear
                            .onAppear {
                                // Capture text width
                                textWidth = textGeo.size.width
                                
                                // Start off-screen right
                                offset = geo.size.width
                                
                                animate(screenWidth: geo.size.width)
                            }
                    }
                )
                .offset(x: offset)
        }
        .clipped()
    }

    /// Infinite scrolling animation
    private func animate(screenWidth: CGFloat) {
        let distance = textWidth + screenWidth
        let duration = distance / speed

        withAnimation(
            .linear(duration: duration)
                .repeatForever(autoreverses: false)
        ) {
            offset = -textWidth
        }
    }
}
