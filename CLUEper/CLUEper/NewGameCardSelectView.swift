//
//  NewGameCardSelectView.swift
//  CLUEper
//

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
        "Candlestick", "Dagger", "Lead Pipe",
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

            if let index = selectedPlayerIndex {
                Text("Select the cards in your hand, \(players[index].name)")
                    .foregroundColor(.secondary)
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
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)

                Button("Start Game") {
                    // save selectedCards → game state
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }

    @ViewBuilder
    private func cardSection(title: String, cards: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                ForEach(cards, id: \.self) { card in
                    Text(card)
                        .font(.subheadline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedCards.contains(card)
                            ? Color.red
                            : Color(.secondarySystemBackground)
                        )
                        .foregroundColor(
                            selectedCards.contains(card)
                            ? .white
                            : .primary
                        )
                        .cornerRadius(12)
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
