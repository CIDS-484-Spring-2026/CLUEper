import SwiftUI

/// Placeholder for "game in progress" screen.
/// (Currently not wired to real game state)
struct HomeView: View {
    var body: some View {
        ZStack {
            
            // Blurred background
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

                // TODO: Hook into actual navigation/state
                Button("Continue Investigation") {
                    print("Continue")
                }

                Button("End Current Game") {
                    print("End Game")
                }
                .foregroundColor(.white.opacity(0.7))

                Button("Start New Game") {
                    print("Start New")
                }

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}