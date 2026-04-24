import Foundation

@MainActor
final class SavedGamesStore: ObservableObject {
    @Published private(set) var games: [SavedGame] = []

    private let defaultsKey = "saved_games"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        load()
    }

    func save(_ game: SavedGame) {
        // Re-save updates an existing game in place; new saves are inserted at the top.
        if let index = games.firstIndex(where: { $0.id == game.id }) {
            games[index] = game
        } else {
            games.insert(game, at: 0)
        }

        games.sort { $0.savedAt > $1.savedAt }
        persist()
    }

    func delete(_ game: SavedGame) {
        games.removeAll { $0.id == game.id }
        persist()
    }

    private func load() {
        // A missing or unreadable payload should fail soft and just show an empty home screen.
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? decoder.decode([SavedGame].self, from: data) else {
            games = []
            return
        }

        games = decoded.sorted { $0.savedAt > $1.savedAt }
    }

    private func persist() {
        guard let data = try? encoder.encode(games) else {
            return
        }

        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}
