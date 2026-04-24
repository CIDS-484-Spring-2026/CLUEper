import SwiftUI

/// Controls multi-step "new game" setup flow
struct NewGameFlowView: View {
    let onStartGame: (SavedGame) -> Void
    let onCancel: () -> Void

    enum Step: Int, CaseIterable {
        case playerCount
        case playerSelect
        case cardSelect
    }

    @State private var step: Step = .playerCount
    @State private var players: [Player] = []
    @State private var selectedPlayerIndex: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Step \(step.rawValue + 1) of \(Step.allCases.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(AppColors.mutedText)
                    .tracking(1.2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 12)

            ProgressBar(step: step)

            switch step {
            case .playerCount:
                NewGamePlayerCountView(
                    players: $players,
                    onCancel: onCancel,
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
                    onBack: { step = .playerSelect },
                    onStartGame: onStartGame
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}
