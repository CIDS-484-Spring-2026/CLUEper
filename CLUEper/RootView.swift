import SwiftUI

/// Root switcher for app state (start vs active game) Currently this file is not in use.
struct RootView: View {
    
    @State private var hasStartedGame = false

    var body: some View {
        Group {
            if hasStartedGame {

                //Replace with HomeView when game state exists
                WelcomeView()
            } else {
                WelcomeView()
            }
        }
    }
}