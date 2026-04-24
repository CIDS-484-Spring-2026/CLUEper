import Foundation

struct AnalysisResult {
    var rooms: [String: Double]
    var suspects: [String: Double]
    var weapons: [String: Double]

    static let empty = AnalysisResult(
        rooms: [:],
        suspects: [:],
        weapons: [:]
    )
}
