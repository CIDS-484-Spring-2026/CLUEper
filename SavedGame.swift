import Foundation

struct SavedGame: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var title: String
    var savedAt: Date
    var players: [String]
    var yourCards: [String]
    var yourPlayerIndex: Int
    var logs: [RoundLog]

    init(
        id: UUID = UUID(),
        title: String,
        savedAt: Date = Date(),
        players: [String],
        yourCards: [String],
        yourPlayerIndex: Int,
        logs: [RoundLog]
    ) {
        self.id = id
        self.title = title
        self.savedAt = savedAt
        self.players = players
        self.yourCards = yourCards
        self.yourPlayerIndex = yourPlayerIndex
        self.logs = logs
    }

    static func defaultTitle(for players: [String]) -> String {
        "\(players.count)-Player Case"
    }
}
