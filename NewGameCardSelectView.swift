import SwiftUI

/// Step 3: Select cards in your hand
struct NewGameCardSelectView: View {

    let players: [Player]
    let selectedPlayerIndex: Int?
    let onBack: () -> Void
    let onStartGame: (SavedGame) -> Void

    @State private var selectedCards: Set<String> = []

    enum CardCategory {
        case suspects, weapons, rooms

        var color: Color {
            switch self {
            case .suspects: return AppColors.accentRed
            case .weapons: return .orange
            case .rooms: return .blue
            }
        }
    }

    var body: some View {
        VStack(spacing: 20) {

            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Which cards do you have?")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("Tap every card in your hand.")
                        .foregroundColor(AppColors.mutedText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            ScrollView {
                VStack(spacing: 28) {
                    cardSection(
                        title: "SUSPECTS",
                        cards: ClueCards.suspects,
                        category: .suspects
                    )

                    cardSection(
                        title: "WEAPONS",
                        cards: ClueCards.weapons,
                        category: .weapons
                    )

                    cardSection(
                        title: "ROOMS",
                        cards: ClueCards.rooms,
                        category: .rooms
                    )
                }
            }

            HStack(spacing: 16) {

                Button("Back") {
                    AppFeedback.tap()
                    onBack()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .foregroundColor(.white)
                .cornerRadius(14)
                .contentShape(Rectangle())
                .buttonStyle(PressableButtonStyle())

                Button("Start Game") {
                    guard let index = selectedPlayerIndex else {
                        return
                    }
                    AppFeedback.success()

                    let game = SavedGame(
                        title: SavedGame.defaultTitle(for: players.map(\.name)),
                        players: players.map(\.name),
                        yourCards: Array(selectedCards).sorted(),
                        yourPlayerIndex: index,
                        logs: []
                    )

                    onStartGame(game)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    selectedCards.isEmpty || selectedPlayerIndex == nil
                    ? Color.gray
                    : AppColors.accentRed
                )
                .foregroundColor(.black)
                .cornerRadius(14)
                .disabled(selectedCards.isEmpty || selectedPlayerIndex == nil)
                .contentShape(Rectangle())
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding()
        .background(AppColors.appBackground.ignoresSafeArea())
    }

    private func cardSection(title: String, cards: [String], category: CardCategory) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Circle()
                    .fill(category.color)
                    .frame(width: 8, height: 8)

                Text(title)
                    .foregroundColor(AppColors.mutedText)
                    .font(.caption)
                    .tracking(1.5)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                ForEach(cards, id: \.self) { card in
                    cardCell(card, category: category)
                }
            }
        }
    }

    private func cardCell(_ card: String, category: CardCategory) -> some View {
        let isSelected = selectedCards.contains(card)

        return Text(card)
            .font(.subheadline.weight(.medium))
            .foregroundColor(isSelected ? .black : .white)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(isSelected ? category.color : AppColors.cardBackgroundStrong)
            )
            .overlay(
                Capsule()
                    .stroke(AppColors.cardBorder, lineWidth: 1)
            )
            .onTapGesture {
                AppFeedback.tap()
                withAnimation(.easeInOut(duration: 0.15)) {
                    if isSelected {
                        selectedCards.remove(card)
                    } else {
                        selectedCards.insert(card)
                    }
                }
            }
    }
}
