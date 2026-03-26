import Foundation

/// Handles logic for building and updating deduction states
struct DeductionEngine {

    /// Cycles a cell through its possible states when tapped
    /// Order: unknown → maybe → no → has → back to unknown
    static func nextState(_ state: CellState) -> CellState {

        switch state {
        case .unknown: return .maybe   // We now suspect this player might have it
        case .maybe: return .no        // We now think they definitely DON'T have it
        case .no: return .has          // We now mark that they DO have it
        case .has: return .unknown     // Reset back to unknown
        }
    }

    /// Builds the initial grid of rows (cards × players)
    ///
    /// - Parameters:
    ///   - names: list of card names (suspects, weapons, or rooms)
    ///   - yourCards: cards YOU personally hold
    ///   - yourIndex: your position in the players array
    ///   - playerCount: total number of players
    ///
    /// - Returns:
    ///   Array of CardRow, each containing a card name and a state per player
    static func buildRows(
        names: [String],
        yourCards: [String],
        yourIndex: Int,
        playerCount: Int
    ) -> [CardRow] {

        // For every card (e.g., "Knife", "Miss Scarlet", etc.)
        names.map { name in

            // Create a state for each player
            let states = (0..<playerCount).map { i -> CellState in

                // If YOU have this card:
                if yourCards.contains(name) {

                    // Mark:
                    // - YOU as having it
                    // - everyone else as NOT having it
                    return i == yourIndex ? .has : .no
                }

                // If YOU do NOT have this card:
                // - YOU cannot have it → mark .no
                // - others are unknown → .unknown
                return i == yourIndex ? .no : .unknown
            }

            // Create a row representing this card across all players
            return CardRow(name: name, states: states)
        }
    }
}
