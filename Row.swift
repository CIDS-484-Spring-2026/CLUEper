import Foundation

struct CardRow: Identifiable {
    let id = UUID()
    let name: String
    var states: [CellState]
}

