import SwiftUI

// MARK: - Model
struct RoundLog: Identifiable, Hashable {
    let id = UUID()
    
    let player: String
    let suspect: String
    let weapon: String
    let room: String
    let shownBy: String?
    let shownCard: String?
}



// MARK: - View
struct RoundLogEntryView: View {
    
    let players: [String]
    let you: String
    var onSave: (RoundLog) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    
    // MARK: Step
    @State private var step = 0
    
    
    // MARK: Selections
    @State private var selectedPlayer = ""
    @State private var suspect = ""
    @State private var weapon = ""
    @State private var room = ""
    @State private var shownBy = ""
    @State private var shownCard = ""
    
    
    // MARK: Data
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
    
    
    // computed card pool
    var allCards: [String] {
        suspects + weapons + rooms
    }
    
    
    // dynamic step count
    var totalSteps: Int {
        selectedPlayer == you ? 6 : 5
    }
    
    
    // MARK: Body
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // working progress bar
                ProgressView(value: Double(step), total: Double(totalSteps-1))
                    .tint(.red)
                
                Spacer()
                
                stepView
                    .transition(.opacity.combined(with: .slide))
                    .animation(.easeInOut(duration: 0.25), value: step)
                
                Spacer()
                
                navButtons
            }
            .padding()
        }
    }
}



// MARK: - Step Switcher
extension RoundLogEntryView {
    
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
            if selectedPlayer == you {
                block("What were you shown?") {
                    cardGrid([suspect, weapon, room, "None"], selection: $shownCard)
                }
            } else {
                block("Who showed a card?") {
                    playerGrid(selection: $shownBy, allowNone: true)
                }
            }
            
        default:
            block("Who showed a card?") {
                playerGrid(selection: $shownBy, allowNone: true)
            }
        }
    }
}



// MARK: - Block Layout
extension RoundLogEntryView {
    
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
    
    func playerGrid(selection: Binding<String>,
                    allowNone: Bool = false) -> some View {
        
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
                            ? playerColor(name)
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
    
    
    func playerColor(_ name: String) -> Color {
        let index = players.firstIndex(of: name) ?? 0
        let colors: [Color] = [.red,.blue,.green,.yellow,.purple,.orange]
        return colors[index % colors.count]
    }
}
