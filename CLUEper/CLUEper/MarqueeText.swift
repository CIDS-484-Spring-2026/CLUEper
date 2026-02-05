//
//  TextBanner.swift
//  CLUEper
//
//  Created by Elijah William Belz on 2/4/26.
//

import Foundation
import SwiftUI

struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double   // smaller = faster

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
                                textWidth = textGeo.size.width
                                offset = geo.size.width
                                animate(screenWidth: geo.size.width)
                            }
                    }
                )
                .offset(x: offset)
        }
        .clipped()
    }

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

