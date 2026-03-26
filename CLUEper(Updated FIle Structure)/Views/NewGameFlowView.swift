import SwiftUI

/// Controls multi-step "new game" setup flow
struct NewGameFlowView: View {

    /// Steps in the flow
    enum Step: Int, CaseIterable {
        case playerCount
        case playerSelect
        case cardSelect
    }

    @State private var step: Step = .playerCount
    @State private var players: [Player] = []
    @State private var selectedPlayerIndex: Int? = nil

    var body: some View {
        VStack {
            
            // Visual step progress
            ProgressBar(step: step)

            // Switch between setup screens
            switch step {

            case .playerCount:
                NewGamePlayerCountView(
                    players: $players,
                    onContinue: { step = .playerSelect }
                )

            case .playerSelect:
                NewGamePlayerSelectView(
                    players: players,
                    selectedPlayerIndex: $selectedPlayerIndex,
                    onBack: { step = .playerCount },
                    onContinue: { step = .cardSelect }
                )

            case .cardSelect:
                NewGameCardSelectView(
                    players: players,
                    selectedPlayerIndex: selectedPlayerIndex,
                    onBack: { step = .playerSelect }
                )
            }
        }
        .navigationTitle("New Game")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}
