import SwiftUI

/// Step 3: Select cards in your hand
struct NewGameCardSelectView: View {
    
    let players: [Player]
    let selectedPlayerIndex: Int?
    let onBack: () -> Void

    @State private var selectedCards: Set<String> = []

    // MARK: - Category Enum
    enum CardCategory {
        case suspects, weapons, rooms
        
        var color: Color {
            switch self {
            case .suspects: return .red
            case .weapons: return .orange
            case .rooms: return .blue
            }
        }
    }

    // MARK: - Computed Player Label from playerselectView
    private var playerLabel: String {
        guard let index = selectedPlayerIndex else { return "Player" }
        return "Player \(index + 1)"
    }

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - Header
            VStack(spacing: 12) {

                // Section title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Select your cards")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text("\(playerLabel), tap the cards you're holding")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // MARK: - Card Sections
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

            // MARK: - Bottom Buttons
            HStack(spacing: 16) {
                
                Button("Back") {
                    onBack()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.15))
                .foregroundColor(.white)
                .cornerRadius(14)

                NavigationLink {
                    if let index = selectedPlayerIndex {
                        DetectiveNotesView(
                            players: players.map { $0.name },
                            yourCards: Array(selectedCards),
                            yourPlayerIndex: index
                        )
                    }
                } label: {
                    Text("Start Game")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedCards.isEmpty || selectedPlayerIndex == nil
                            ? Color.gray
                            : Color.red
                        )
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
                .disabled(selectedCards.isEmpty || selectedPlayerIndex == nil)
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
    }

    // MARK: - Card Section
    private func cardSection(title: String, cards: [String], category: CardCategory) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            // Section header with colored dot
            HStack(spacing: 8) {
                Circle()
                    .fill(category.color)
                    .frame(width: 8, height: 8)

                Text(title)
                    .foregroundColor(.gray)
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

    // MARK: - Card Cell
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
                    .fill(isSelected ? category.color : Color.gray.opacity(0.15))
            )
            .overlay(
                Capsule()
                    .stroke(Color.gray.opacity(0.25), lineWidth: 1)
            )
            .onTapGesture {
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
