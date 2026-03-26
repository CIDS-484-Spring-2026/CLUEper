import SwiftUI

/// Player model used during setup and gameplay
struct Player: Identifiable, Equatable {
    let id = UUID()
    
    /// Player display name
    var name: String
    
    /// Assigned color (used in UI)
    var color: Color
}
