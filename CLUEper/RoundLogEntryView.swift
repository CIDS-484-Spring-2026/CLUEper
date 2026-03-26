import SwiftUI

// MARK: - Model
/// Represents a single turn (suggestion) in the game log.
/// Conforms to Identifiable so it can be used in SwiftUI lists.
struct RoundLog: Identifiable, Hashable {
    let id = UUID()
    
    /// The player who made the suggestion
    let player: String
    
    /// The suggested suspect, weapon, and room
    let suspect: String
    let weapon: String
    let room: String
    
    /// Who showed a card (if any)
    let shownBy: String?
    
    /// The exact card shown (only known if YOU saw it)
    let shownCard: String?
}



// MARK: - View
/// Multi-step form for logging a round in the game.
/// Walks the user through selecting player, cards, and outcomes.
struct RoundLogEntryView: View {
    
    /// All players in the game
    let players: [String]
    
    /// The current user (important for logic differences)
    let you: String
    
    /// Callback when a log is saved
    var onSave: (RoundLog) -> Void
    
    /// Used to dismiss the sheet
    @Environment(\.dismiss) private var dismiss
    
    
    // MARK: Step
    /// Current step in the multi-step flow
    @State private var step = 0
    
    
    // MARK: Selections
    /// User selections throughout the flow
    @State private var selectedPlayer = ""
    @State private var suspect = ""
    @State private var weapon = ""
    @State private var room = ""
    @State private var shownBy = ""
    @State private var shownCard = ""
    
    
    // MARK: Data
    /// Static Clue card sets
    private let suspects = [
        "Miss Scarlet","Colonel Mustard","Mrs. White",
        "Mr. Green","Mrs. Peacock","Professor Plum"
    ]
    
    private let weapons = [
        "Knife","Candlestick","Revolver",
        "Rope","Lead Pipe","Wrench"
    ]
    
    private let rooms = [
        "Kitchen","Ballroom","Conservatory",
        "Dining Room","Library","Study"
    ]
    
    
    /// All possible cards combined (useful for future logic)
    var allCards: [String] {
        suspects + weapons + rooms
    }
    
    
    /// Total steps changes depending on whether YOU made the guess
    /// (because you may know the exact card shown)
    var totalSteps: Int {
        selectedPlayer == you ? 6 : 5
    }
    
    
    // MARK: Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                /// Progress bar based on step
                ProgressView(value: Double(step), total: Double(totalSteps-1))
                    .tint(.red)
                
                Spacer()
                
                /// Dynamic step content
                stepView
                    .transition(.opacity.combined(with: .slide))
                    .animation(.easeInOut(duration: 0.25), value: step)
                
                Spacer()
                
                /// Navigation (Back / Next / Save)
                navButtons
            }
            .padding()
        }
    }
}



// MARK: - Step Switcher
extension RoundLogEntryView {
    
    /// Returns the correct UI for the current step
    @ViewBuilder
    var stepView: some View {
        
        switch step {
            
        case 0:
            block("Who is guessing?") {
                playerGrid(selection: $selectedPlayer)
            }
            
        case 1:
            block("Which Room?") {
                cardGrid(rooms, selection: $room)
            }
            
        case 2:
            block("Which Weapon?") {
                cardGrid(weapons, selection: $weapon)
            }
            
        case 3:
            block("Which Suspect?") {
                cardGrid(suspects, selection: $suspect)
            }
            
        case 4:
            /// If YOU made the guess, you know exactly what card you saw
            if selectedPlayer == you {
                block("What were you shown?") {
                    cardGrid([suspect, weapon, room, "None"], selection: $shownCard)
                }
            } else {
                /// Otherwise, you only know who showed a card
                block("Who showed a card?") {
                    playerGrid(selection: $shownBy, allowNone: true)
                }
            }
            
        default:
            /// Final fallback step (only used in extended flow)
            block("Who showed a card?") {
                playerGrid(selection: $shownBy, allowNone: true)
            }
        }
    }
}



// MARK: - Block Layout
extension RoundLogEntryView {
    
    /// Reusable layout block with title + content
    func block<Content: View>(_ title: String,
                              @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 22) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            content()
        }
    }
}



// MARK: - Player Grid
extension RoundLogEntryView {
    
    /// Grid of selectable players
    func playerGrid(selection: Binding<String>,
                    allowNone: Bool = false) -> some View {
        
        /// Optionally include "None"
        let options = allowNone ? players + ["None"] : players
        
        return LazyVGrid(columns: [.init(.adaptive(minimum: 120))], spacing: 12) {
            
            ForEach(options, id: \.self) { name in
                
                let selected = selection.wrappedValue == name
                
                Button {
                    selection.wrappedValue = name
                } label: {
                    Text(name)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selected
                            ? playerColor(name)   /// Highlight selected player
                            : Color.white.opacity(0.08)
                        )
                        .cornerRadius(12)
                }
            }
        }
    }
}



// MARK: - Card Grid
extension RoundLogEntryView {
    
    /// Generic grid for selecting cards (suspect/weapon/room)
    func cardGrid(_ items: [String],
                  selection: Binding<String>) -> some View {
        
        LazyVGrid(columns: [.init(.adaptive(minimum: 120))], spacing: 12) {
            
            ForEach(items, id: \.self) { item in
                
                let selected = selection.wrappedValue == item
                
                Button {
                    selection.wrappedValue = item
                } label: {
                    Text(item)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            selected
                            ? Color.orange
                            : Color.white.opacity(0.08)
                        )
                        .cornerRadius(12)
                }
            }
        }
    }
}



// MARK: - Navigation
extension RoundLogEntryView {
    
    /// Bottom navigation buttons (Back / Next / Save)
    var navButtons: some View {
        HStack {
            
            if step > 0 {
                Button("Back") { step -= 1 }
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(step == totalSteps-1 ? "Save" : "Next") {
                
                if step == totalSteps-1 {
                    save()
                } else {
                    step += 1
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 12)
            .background(canContinue ? Color.red : Color.gray)
            .cornerRadius(14)
            .disabled(!canContinue)
        }
    }
}



// MARK: - Logic
extension RoundLogEntryView {
    
    /// Determines if user can proceed to next step
    var canContinue: Bool {
        switch step {
        case 0: return !selectedPlayer.isEmpty
        case 1: return !room.isEmpty
        case 2: return !weapon.isEmpty
        case 3: return !suspect.isEmpty
        case 4:
            return selectedPlayer == you
                ? !shownCard.isEmpty
                : true
        default:
            return true
        }
    }
    
    
    /// Builds and saves the RoundLog model
    func save() {
        let log = RoundLog(
            player: selectedPlayer,
            suspect: suspect,
            weapon: weapon,
            room: room,
            shownBy: shownBy == "None" ? nil : shownBy,
            shownCard: (shownCard.isEmpty || shownCard == "None") ? nil : shownCard
        )
        
        onSave(log)
        dismiss()
    }
    
    
    /// Assigns consistent colors to players based on index
    func playerColor(_ name: String) -> Color {
        let index = players.firstIndex(of: name) ?? 0
        let colors: [Color] = [.red,.blue,.green,.yellow,.purple,.orange]
        return colors[index % colors.count]
    }
}