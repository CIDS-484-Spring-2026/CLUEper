import SwiftUI

/// Horizontally scrolling text (ticker/marquee effect)
struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double   // pixels per second

    @State private var contentWidth: CGFloat = 0

    private var marqueeContent: String {
        "\(text)   •   "
    }

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { context in
                HStack(spacing: 0) {
                    ForEach(0..<repetitionCount(containerWidth: geo.size.width), id: \.self) { _ in
                        tickerText
                    }
                }
                .offset(x: xOffset(for: context.date))
            }
        }
        .clipped()
    }

    private var tickerText: some View {
        Text(marqueeContent)
            .font(font)
            .foregroundColor(.white.opacity(0.7))
            .fixedSize()
            .background(
                GeometryReader { textGeo in
                    Color.clear
                        .onAppear {
                            contentWidth = textGeo.size.width
                        }
                        .onChange(of: textGeo.size.width) { newValue in
                            contentWidth = newValue
                        }
                }
            )
    }

    private func repetitionCount(containerWidth: CGFloat) -> Int {
        guard contentWidth > 0 else {
            return 3
        }

        return max(Int(ceil(containerWidth / contentWidth)) + 2, 3)
    }

    private func xOffset(for date: Date) -> CGFloat {
        guard contentWidth > 0 else {
            return 0
        }

        let traveled = CGFloat(date.timeIntervalSinceReferenceDate) * speed
        return -traveled.truncatingRemainder(dividingBy: contentWidth)
    }
}
