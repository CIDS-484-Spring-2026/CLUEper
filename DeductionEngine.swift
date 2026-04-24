import Foundation

/// Applies hard logic to the notes grid after the game has started.
struct DeductionEngine {

    struct OwnershipFact: Hashable {
        let card: String
        let playerIndex: Int
        let state: CellState
    }

    static func nextState(_ state: CellState) -> CellState {
        switch state {
        case .unknown: return .maybe
        case .maybe: return .no
        case .no: return .has
        case .has: return .unknown
        }
    }

    static func updateNotesGrid(
        baseGrid: GameSetupEngine.Grid,
        logs: [RoundLog],
        players: [String],
        inferredFacts: [OwnershipFact] = []
    ) -> GameSetupEngine.Grid {
        var grid = baseGrid
        var didChange = true

        // Keep looping until no new facts can be derived. Several rules unlock later rules,
        // so a single pass is not enough once the grid starts collapsing.
        while didChange {
            didChange = false
            didChange = applyKnownLogFacts(logs, players: players, to: &grid) || didChange
            didChange = applyInferredFacts(inferredFacts, to: &grid) || didChange
            didChange = applyUnknownCardShowFacts(logs, players: players, to: &grid) || didChange
            didChange = resolveUnknownShownCards(logs, players: players, in: &grid) || didChange
            didChange = normalizeKnownOwnership(in: &grid) || didChange
        }

        return grid
    }
}

private extension DeductionEngine {

    static func applyKnownLogFacts(
        _ logs: [RoundLog],
        players: [String],
        to grid: inout GameSetupEngine.Grid
    ) -> Bool {
        var changed = false

        for log in logs {
            if let shownCard = log.shownCard,
               let shownBy = log.shownBy,
               let shownIndex = players.firstIndex(of: shownBy) {
                changed = setState(.has, for: shownIndex, card: shownCard, in: &grid) || changed

                for playerIndex in players.indices where playerIndex != shownIndex {
                    changed = setState(.no, for: playerIndex, card: shownCard, in: &grid) || changed
                }
            }

            if log.shownBy == nil {
                
                // If nobody could answer, every other player can be ruled out for all three cards.
                let askerIndex = players.firstIndex(of: log.player)

                for card in cards(in: log) {
                    for playerIndex in players.indices where playerIndex != askerIndex {
                        changed = setState(.no, for: playerIndex, card: card, in: &grid) || changed
                    }
                }
            }
        }

        return changed
    }

    static func applyInferredFacts(
        _ facts: [OwnershipFact],
        to grid: inout GameSetupEngine.Grid
    ) -> Bool {
        var changed = false

        for fact in facts {
            changed = setState(fact.state, for: fact.playerIndex, card: fact.card, in: &grid) || changed
        }

        return changed
    }

    static func applyUnknownCardShowFacts(
        _ logs: [RoundLog],
        players: [String],
        to grid: inout GameSetupEngine.Grid
    ) -> Bool {
        var changed = false

        for log in logs where log.shownBy != nil && log.shownCard == nil {
            guard let shownBy = log.shownBy,
                  let shownIndex = players.firstIndex(of: shownBy) else {
                continue
            }

            for card in cards(in: log) {
                changed = setMaybe(for: shownIndex, card: card, in: &grid) || changed
            }
        }

        return changed
    }

    static func resolveUnknownShownCards(
        _ logs: [RoundLog],
        players: [String],
        in grid: inout GameSetupEngine.Grid
    ) -> Bool {
        var changed = false

        for log in logs where log.shownCard == nil {
            guard let shownBy = log.shownBy,
                  let shownIndex = players.firstIndex(of: shownBy) else {
                continue
            }

            let candidates = cards(in: log).filter {
                state(for: $0, playerIndex: shownIndex, in: grid) != .no
            }

            // Once only one candidate survives for a hidden show, that card becomes known.
            if candidates.count == 1, let card = candidates.first {
                changed = setState(.has, for: shownIndex, card: card, in: &grid) || changed
            }
        }

        return changed
    }

    static func normalizeKnownOwnership(in grid: inout GameSetupEngine.Grid) -> Bool {
        var changed = false

        for row in grid.suspects.indices {
            changed = normalize(row: &grid.suspects[row]) || changed
        }

        for row in grid.weapons.indices {
            changed = normalize(row: &grid.weapons[row]) || changed
        }

        for row in grid.rooms.indices {
            changed = normalize(row: &grid.rooms[row]) || changed
        }

        return changed
    }

    static func normalize(row: inout CardRow) -> Bool {
        // A known owner for a card automatically rules out every other player.
        guard let ownerIndex = row.states.firstIndex(of: .has) else {
            return false
        }

        var changed = false

        for index in row.states.indices where index != ownerIndex {
            if row.states[index] != .no {
                row.states[index] = .no
                changed = true
            }
        }

        return changed
    }

    static func cards(in log: RoundLog) -> [String] {
        [log.suspect, log.weapon, log.room]
    }

    static func state(
        for card: String,
        playerIndex: Int,
        in grid: GameSetupEngine.Grid
    ) -> CellState {
        if let row = grid.suspects.first(where: { $0.name == card }) {
            return row.states[playerIndex]
        }

        if let row = grid.weapons.first(where: { $0.name == card }) {
            return row.states[playerIndex]
        }

        if let row = grid.rooms.first(where: { $0.name == card }) {
            return row.states[playerIndex]
        }

        return .unknown
    }

    static func setState(
        _ newState: CellState,
        for playerIndex: Int,
        card: String,
        in grid: inout GameSetupEngine.Grid
    ) -> Bool {
        update(card: card, rows: &grid.suspects, playerIndex: playerIndex, newState: newState)
            || update(card: card, rows: &grid.weapons, playerIndex: playerIndex, newState: newState)
            || update(card: card, rows: &grid.rooms, playerIndex: playerIndex, newState: newState)
    }

    static func setMaybe(
        for playerIndex: Int,
        card: String,
        in grid: inout GameSetupEngine.Grid
    ) -> Bool {
        updateMaybe(card: card, rows: &grid.suspects, playerIndex: playerIndex)
            || updateMaybe(card: card, rows: &grid.weapons, playerIndex: playerIndex)
            || updateMaybe(card: card, rows: &grid.rooms, playerIndex: playerIndex)
    }

    static func update(
        card: String,
        rows: inout [CardRow],
        playerIndex: Int,
        newState: CellState
    ) -> Bool {
        guard let rowIndex = rows.firstIndex(where: { $0.name == card }) else {
            return false
        }

        let currentState = rows[rowIndex].states[playerIndex]
        if currentState == newState {
            return false
        }

        if currentState == .has && newState != .has {
            return false
        }

        rows[rowIndex].states[playerIndex] = newState
        return true
    }

    static func updateMaybe(
        card: String,
        rows: inout [CardRow],
        playerIndex: Int
    ) -> Bool {
        guard let rowIndex = rows.firstIndex(where: { $0.name == card }) else {
            return false
        }

        let currentState = rows[rowIndex].states[playerIndex]
        guard currentState == .unknown else {
            return false
        }

        rows[rowIndex].states[playerIndex] = .maybe
        return true
    }
}
