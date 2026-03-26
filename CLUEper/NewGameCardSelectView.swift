import SwiftUI

/// Step 3: Select cards in your hand
struct NewGameCardSelectView: View {
    
    let players: [Player]
    let selectedPlayerIndex: Int?
    let onBack: () -> Void

    @State private var selectedCards: Set<String> = []

    var body: some View {
        VStack {

            Text("What cards do you have?")

            // Card sections (suspects/weapons/rooms)
            ScrollView {
                VStack {
                    cardSection(title: "Suspects", cards: suspects)
                    cardSection(title: "Weapons", cards: weapons)
                    cardSection(title: "Rooms", cards: rooms)
                }
            }

            HStack {
                Button("Back", action: onBack)

                // Starts game -> opens DetectiveNotesView
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
                }
                .disabled(selectedCards.isEmpty || selectedPlayerIndex == nil)
            }
        }
    }

    /// Reusable card grid
    private func cardSection(title: String, cards: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))]) {
            ForEach(cards, id: \.self) { card in
                Text(card)
                    .onTapGesture {
                        // Toggle selection
                        if selectedCards.contains(card) {
                            selectedCards.remove(card)
                        } else {
                            selectedCards.insert(card)
                        }
                    }
            }
        }
    }
}