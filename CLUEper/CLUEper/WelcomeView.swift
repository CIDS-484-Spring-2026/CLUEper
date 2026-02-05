import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Background image
                Image("Start_Screen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Dark overlay
                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                // Main content
                VStack(spacing: 6) {
                    Spacer()

                    // Logo
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 90, weight: .bold))
                        .foregroundColor(.black)

                    // App name
                    Text("CLUEper")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()
                    // New Game button
                    NavigationLink {
                        NewGameFlowView()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("New Game")
                                .fontWeight(.semibold)
                        }
                        .frame(width: 220, height: 50)
                        .background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    }

                    Spacer()

                    // Marquee text
                    MarqueeText(
                        text: "Track suspects, weapons, and rooms as you solve the mystery. Never run out of notecards again!",
                        font: .footnote,
                        speed: 70
                    )
                    .frame(height: 20)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(14)
                    .padding(.horizontal)
                }
            }
        }
    }
}





// Xcode 14 preview support
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .preferredColorScheme(.dark)
    }
}
