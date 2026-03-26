import Foundation

struct LogEntry: Identifiable, Codable {

    let id = UUID()

    var asker: String
    var suspect: String
    var weapon: String
    var room: String

    var shownBy: String?
    var shownCard: String?
}
