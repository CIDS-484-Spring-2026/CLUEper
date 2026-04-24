import Foundation

/// Estimates how dangerous each opponent is from what they could know in-game.
struct PlayerStatusEngine {

    struct ThreatStatus {
        let name: String
        let progress: Double
        let label: String
        let detail: String
    }

    static func assess(
        players: [String],
        yourPlayerName: String,
        logs: [RoundLog],
        suspects: [CardRow],
        weapons: [CardRow],
        rooms: [CardRow]
    ) -> [ThreatStatus] {
        let allRows = suspects + weapons + rooms

        return players
            .filter { $0 != yourPlayerName }
            .compactMap { playerName in
                guard let playerIndex = players.firstIndex(of: playerName) else {
                    return nil
                }

                let ownCards = Set(
                    allRows.compactMap { row in
                        row.states[playerIndex] == .has ? row.name : nil
                    }
                )

                var suspectCandidates = Set(ClueCards.suspects.filter { !ownCards.contains($0) })
                var weaponCandidates = Set(ClueCards.weapons.filter { !ownCards.contains($0) })
                var roomCandidates = Set(ClueCards.rooms.filter { !ownCards.contains($0) })

                var partialClues = 0

                for log in logs where log.player == playerName {
                    let unknownAccusedCards = [log.suspect, log.weapon, log.room].filter {
                        !ownCards.contains($0)
                    }

                    if log.shownBy == nil {
                        forceEnvelopeCard(log.suspect, into: &suspectCandidates)
                        forceEnvelopeCard(log.weapon, into: &weaponCandidates)
                        forceEnvelopeCard(log.room, into: &roomCandidates)
                        continue
                    }

                    if let shownCard = log.shownCard {
                        removeFromCandidates(
                            shownCard,
                            suspects: &suspectCandidates,
                            weapons: &weaponCandidates,
                            rooms: &roomCandidates
                        )
                        continue
                    }

                    if unknownAccusedCards.count == 1, let knownShownCard = unknownAccusedCards.first {
                        removeFromCandidates(
                            knownShownCard,
                            suspects: &suspectCandidates,
                            weapons: &weaponCandidates,
                            rooms: &roomCandidates
                        )
                    } else if !unknownAccusedCards.isEmpty {
                        partialClues += 1
                    }
                }

                let suspectKnowledge = knowledgeScore(
                    candidateCount: suspectCandidates.count,
                    totalCount: ClueCards.suspects.count
                )
                let weaponKnowledge = knowledgeScore(
                    candidateCount: weaponCandidates.count,
                    totalCount: ClueCards.weapons.count
                )
                let roomKnowledge = knowledgeScore(
                    candidateCount: roomCandidates.count,
                    totalCount: ClueCards.rooms.count
                )

                let resolvedCategories = [
                    suspectCandidates.count,
                    weaponCandidates.count,
                    roomCandidates.count
                ].filter { $0 == 1 }.count

                let narrowedCategories = [
                    suspectCandidates.count,
                    weaponCandidates.count,
                    roomCandidates.count
                ].filter { $0 <= 2 }.count

                let progress = min(
                    ((suspectKnowledge + weaponKnowledge + roomKnowledge) / 3.0)
                        + min(Double(partialClues) * 0.06, 0.18),
                    1.0
                )

                return ThreatStatus(
                    name: playerName,
                    progress: progress,
                    label: threatLabel(for: progress),
                    detail: detailText(
                        resolvedCategories: resolvedCategories,
                        narrowedCategories: narrowedCategories,
                        partialClues: partialClues
                    )
                )
            }
    }
}

private extension PlayerStatusEngine {

    static func forceEnvelopeCard(_ card: String, into candidates: inout Set<String>) {
        guard candidates.contains(card) else {
            return
        }

        candidates = [card]
    }

    static func removeFromCandidates(
        _ card: String,
        suspects: inout Set<String>,
        weapons: inout Set<String>,
        rooms: inout Set<String>
    ) {
        suspects.remove(card)
        weapons.remove(card)
        rooms.remove(card)
    }

    static func knowledgeScore(candidateCount: Int, totalCount: Int) -> Double {
        guard totalCount > 1 else {
            return candidateCount == 1 ? 1.0 : 0.0
        }

        let normalized = 1.0 - (Double(max(candidateCount - 1, 0)) / Double(totalCount - 1))
        return max(0.0, min(normalized, 1.0))
    }

    static func threatLabel(for progress: Double) -> String {
        switch progress {
        case 0.75...:
            return "High Threat"
        case 0.4..<0.75:
            return "Medium Threat"
        default:
            return "Low Threat"
        }
    }

    static func detailText(
        resolvedCategories: Int,
        narrowedCategories: Int,
        partialClues: Int
    ) -> String {
        if resolvedCategories > 0 {
            return "\(resolvedCategories) categories narrowed to one card"
        }

        if narrowedCategories > 0 {
            return "\(narrowedCategories) categories narrowed to two or fewer cards"
        }

        if partialClues > 0 {
            return "\(partialClues) accusation clues without an exact reveal"
        }

        return "Mostly broad early-round information"
    }
}
