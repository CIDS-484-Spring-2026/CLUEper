import SwiftUI

struct NewGameCardSelectView: View {
    let players: [Player]
    let selectedPlayerIndex: Int?

    let onBack: () -> Void

    // Starter Clue cards (classic set)
    let suspects = [
        "Miss Scarlet", "Colonel Mustard", "Mrs. White",
        "Mr. Green", "Mrs. Peacock", "Professor Plum"
    ]

    let weapons = [
        "Candlestick", "Knife", "Lead Pipe",
        "Revolver", "Rope", "Wrench"
    ]

    let rooms = [
        "Kitchen", "Ballroom", "Conservatory",
        "Dining Room", "Billiard Room", "Library",
        "Lounge", "Hall", "Study"
    ]

    @State private var selectedCards: Set<String> = []

    var body: some View {
        VStack(spacing: 20) {

            Text("What cards do you have?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            if let index = selectedPlayerIndex {
                Text("Select the cards in your hand, \(players[index].name)")
                    .foregroundColor(.gray)
            }

            ScrollView {
                VStack(spacing: 24) {
                    cardSection(title: "Suspects", cards: suspects)
                    cardSection(title: "Weapons", cards: weapons)
                    cardSection(title: "Rooms", cards: rooms)
                }
            }

            HStack {
                Button("Back") {
                    onBack()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(12)

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
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
                .disabled(selectedCards.isEmpty || selectedPlayerIndex == nil)
                .opacity(selectedCards.isEmpty || selectedPlayerIndex == nil ? 0.5 : 1)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        
        
        //Hides Navigation Link Back Button & Disables it
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)
    }

    @ViewBuilder
    private func cardSection(title: String, cards: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                ForEach(cards, id: \.self) { card in
                    Text(card)
                        .font(.subheadline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedCards.contains(card)
                            ? Color.red
                            : Color.white.opacity(0.06)
                        )
                        .foregroundColor(
                            selectedCards.contains(card)
                            ? .black
                            : .white
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedCards.contains(card)
                                    ? Color.red
                                    : Color.white.opacity(0.15),
                                    lineWidth: 2
                                )
                        )
                        .onTapGesture {
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
}
