import Foundation

class GameViewModel: ObservableObject {

    @Published var players: [Player] = []
    @Published var suspects: [CardRow] = []
    @Published var weapons: [CardRow] = []
    @Published var rooms: [CardRow] = []
    @Published var logs: [LogEntry] = []

    var yourIndex = 0
    var yourCards: [String] = []

    func startGame(players: [Player], yourIndex: Int, yourCards: [String]) {

        self.players = players
        self.yourIndex = yourIndex
        self.yourCards = yourCards

        let initialGrid = GameSetupEngine.makeInitialGrid(
            players: players.map(\.name),
            yourCards: yourCards,
            yourPlayerIndex: yourIndex
        )

        suspects = initialGrid.suspects
        weapons = initialGrid.weapons
        rooms = initialGrid.rooms
    }

    func toggleCell(category: String, rowId: String, column: Int) {

        guard column != yourIndex else { return }

        func update(_ rows: inout [CardRow]) {

            if let i = rows.firstIndex(where: { $0.name == rowId }) {

                rows[i].states[column] =
                    DeductionEngine.nextState(rows[i].states[column])
            }
        }

        switch category {
        case "suspects": update(&suspects)
        case "weapons": update(&weapons)
        case "rooms": update(&rooms)
        default: break
        }
    }
}
