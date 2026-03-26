import Foundation

enum CellState {
    case unknown
    case has
    case no
    case maybe
    
    func next() -> CellState {
        switch self {
        case .unknown: return .has
        case .has: return .no
        case .no: return .maybe
        case .maybe: return .unknown
        }
    }
}
