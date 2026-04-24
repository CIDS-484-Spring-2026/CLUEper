import Foundation

/// Builds the starting notes grid once at the beginning of a game.
struct GameSetupEngine {

    struct Grid {
        var suspects: [CardRow]
        var weapons: [CardRow]
        var rooms: [CardRow]
    }

    static func makeInitialGrid(
        players: [String],
        yourCards: [String],
        yourPlayerIndex: Int
    ) -> Grid {
        Grid(
            suspects: buildRows(
                names: ClueCards.suspects,
                yourCards: yourCards,
                yourIndex: yourPlayerIndex,
                playerCount: players.count
            ),
            weapons: buildRows(
                names: ClueCards.weapons,
                yourCards: yourCards,
                yourIndex: yourPlayerIndex,
                playerCount: players.count
            ),
            rooms: buildRows(
                names: ClueCards.rooms,
                yourCards: yourCards,
                yourIndex: yourPlayerIndex,
                playerCount: players.count
            )
        )
    }

    static func buildRows(
        names: [String],
        yourCards: [String],
        yourIndex: Int,
        playerCount: Int
    ) -> [CardRow] {
        names.map { name in
            
            // At setup, your own cards are the only hard facts we know.
            let states = (0..<playerCount).map { index -> CellState in
                if yourCards.contains(name) {
                    return index == yourIndex ? .has : .no
                }

                return index == yourIndex ? .no : .unknown
            }

            return CardRow(name: name, states: states)
        }
    }
}
