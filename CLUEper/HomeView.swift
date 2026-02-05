//
//  HomeView.swift
//  CLUEper
//
//  Created by Elijah William Belz on 2/3/26.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            Image("Start_Screen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .blur(radius: 12)

            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("CLUEper")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("GAME IN PROGRESS")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                Button("Continue Investigation") {
                    print("Continue")
                }
                //.buttonStyle(PrimaryButtonStyle())

                Button("End Current Game") {
                    print("End Game")
                }
                .foregroundColor(.white.opacity(0.7))

                Button("Start New Game") {
                    print("Start New")
                }
               // .buttonStyle(SecondaryButtonStyle())

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

// Xcode 14 preview support
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}
