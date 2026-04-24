import Foundation

/// Produces probability-only analysis from the round log stream.
struct AnalysisEngine {

    struct AnalysisOutput {
        let result: AnalysisResult
        let hardFacts: [DeductionEngine.OwnershipFact]
    }

    static func analyze(
        logs: [RoundLog],
        players: [String],
        yourCards: [String],
        yourPlayerName: String
    ) -> AnalysisOutput {
        
        // A fully unanswered accusation made by you is stronger than probability scoring,
        // because you know none of the accused cards are in your hand.
        let certainty = certaintyFromUnansweredOwnAccusation(
            logs: logs,
            yourCards: yourCards,
            yourPlayerName: yourPlayerName
        )

        let suspects = certainty?.suspects
            ?? envelopeProbabilities(for: ClueCards.suspects, logs: logs, yourCards: yourCards)
        let weapons = certainty?.weapons
            ?? envelopeProbabilities(for: ClueCards.weapons, logs: logs, yourCards: yourCards)
        let rooms = certainty?.rooms
            ?? envelopeProbabilities(for: ClueCards.rooms, logs: logs, yourCards: yourCards)

        let result = AnalysisResult(
            rooms: rooms,
            suspects: suspects,
            weapons: weapons
        )

        return AnalysisOutput(
            result: result,
            hardFacts: hardFacts(from: result, playerCount: players.count)
        )
    }

    static func applyKnownEnvelopeCards(
        from grid: GameSetupEngine.Grid,
        to result: AnalysisResult
    ) -> AnalysisResult {
        
        // The notes grid can hard-deduce an envelope card before the probability model does.
        // When every player has an X for a row, that row should override the softer analysis.
        AnalysisResult(
            rooms: mergeKnownEnvelopeCards(into: result.rooms, rows: grid.rooms),
            suspects: mergeKnownEnvelopeCards(into: result.suspects, rows: grid.suspects),
            weapons: mergeKnownEnvelopeCards(into: result.weapons, rows: grid.weapons)
        )
    }
}

private extension AnalysisEngine {

    static func certaintyFromUnansweredOwnAccusation(
        logs: [RoundLog],
        yourCards: [String],
        yourPlayerName: String
    ) -> AnalysisResult? {
        for log in logs.reversed() where log.player == yourPlayerName {
            guard log.shownBy == nil else {
                continue
            }

            let accusedCards = [log.suspect, log.weapon, log.room]
            guard accusedCards.allSatisfy({ !yourCards.contains($0) }) else {
                continue
            }

            return AnalysisResult(
                rooms: certaintyMap(for: ClueCards.rooms, certainCard: log.room),
                suspects: certaintyMap(for: ClueCards.suspects, certainCard: log.suspect),
                weapons: certaintyMap(for: ClueCards.weapons, certainCard: log.weapon)
            )
        }

        return nil
    }

    static func envelopeProbabilities(
        for cards: [String],
        logs: [RoundLog],
        yourCards: [String]
    ) -> [String: Double] {
        // Start every unknown card with equal weight, then push weight away from shown cards
        // and toward accusations that nobody could answer.
        var scores = Dictionary(uniqueKeysWithValues: cards.map { card in
            (card, yourCards.contains(card) ? 0.0 : 1.0)
        })

        for log in logs {
            if let shownCard = log.shownCard, scores.keys.contains(shownCard) {
                scores[shownCard] = 0
            }

            if log.shownBy == nil {
                for card in [log.suspect, log.weapon, log.room] where scores.keys.contains(card) {
                    if scores[card] != 0 {
                        scores[card, default: 0] += 2.5
                    }
                }
            }
        }

        let total = scores.values.reduce(0, +)
        guard total > 0 else {
            return Dictionary(uniqueKeysWithValues: cards.map { ($0, 0.0) })
        }

        return scores.mapValues { $0 / total }
    }

    static func certaintyMap(
        for cards: [String],
        certainCard: String
    ) -> [String: Double] {
        Dictionary(uniqueKeysWithValues: cards.map { card in
            (card, card == certainCard ? 1.0 : 0.0)
        })
    }

    static func mergeKnownEnvelopeCards(
        into probabilities: [String: Double],
        rows: [CardRow]
    ) -> [String: Double] {
        let knownEnvelopeCards = rows
            .filter { $0.states.allSatisfy { $0 == .no } }
            .map(\.name)

        guard let certainCard = knownEnvelopeCards.first else {
            return probabilities
        }

        return certaintyMap(for: rows.map(\.name), certainCard: certainCard)
    }

    static func hardFacts(
        from result: AnalysisResult,
        playerCount: Int
    ) -> [DeductionEngine.OwnershipFact] {
        // A card at 100% envelope probability means no player can hold it,
        // so we feed that back into deduction as explicit "no" facts.
        var facts: [DeductionEngine.OwnershipFact] = []

        for card in certainCards(in: result.suspects) + certainCards(in: result.weapons) + certainCards(in: result.rooms) {
            for playerIndex in 0..<playerCount {
                facts.append(
                    DeductionEngine.OwnershipFact(
                        card: card,
                        playerIndex: playerIndex,
                        state: .no
                    )
                )
            }
        }

        return facts
    }

    static func certainCards(in probabilities: [String: Double]) -> [String] {
        probabilities.compactMap { card, probability in
            probability >= 0.999 ? card : nil
        }
    }
}
