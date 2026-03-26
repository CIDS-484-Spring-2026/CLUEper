import SwiftUI

/// Entry screen of the app.
/// Shows branding + navigation into the new game flow.
struct WelcomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                
                // Background image (full screen)
                Image("Start_Screen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                // Dark overlay for readability
                Color.black.opacity(0.35)
                    .ignoresSafeArea()

                VStack(spacing: 6) {
                    Spacer()

                    // App icon (SF Symbol)
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 90, weight: .bold))
                        .foregroundColor(.black)

                    // App title
                    Text("CLUEper")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.black)

                    Spacer()
                    
                    // Navigates into game setup flow
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

                    // Scrolling description text
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
