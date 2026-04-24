import SwiftUI

// Model
struct RoundLog: Identifiable, Hashable, Codable {
    let id: UUID

    let player: String
    let suspect: String
    let weapon: String
    let room: String

    let shownBy: String?
    let shownCard: String?

    init(
        id: UUID = UUID(),
        player: String,
        suspect: String,
        weapon: String,
        room: String,
        shownBy: String?,
        shownCard: String?
    ) {
        self.id = id
        self.player = player
        self.suspect = suspect
        self.weapon = weapon
        self.room = room
        self.shownBy = shownBy
        self.shownCard = shownCard
    }
}


// Main View
struct RoundLogEntryView: View {

    let players: [String]
    let you: String
    let yourCards: [String]
    var onSave: (RoundLog) -> Void

    // Step
    @State private var step = 0

    // Question selections
    @State private var selectedPlayer = ""
    @State private var suspect = ""
    @State private var weapon = ""
    @State private var room = ""
    @State private var shownBy = ""
    @State private var shownCard = ""

    // Data
    private let suspects = ClueCards.suspects
    private let weapons = ClueCards.weapons
    private let rooms = ClueCards.rooms

    var totalSteps: Int {
        // When you are the accuser, the flow needs one extra step if a real card was shown,
        // because the app must also ask who showed it.
        if selectedPlayer != you {
            return 5
        }

        return shownCard == "None" ? 5 : 6
    }

    var shownCardOptions: [String] {
        [suspect, weapon, room]
            .filter { !yourCards.contains($0) } + ["None"]
    }

    var accusedCards: [String] {
        [suspect, weapon, room]
    }

    var excludedShowersForOtherPlayerTurn: [String] {
        var excluded = [selectedPlayer]

        // If none of the accused cards are in your hand, you cannot be the unknown shower.
        if accusedCards.allSatisfy({ !yourCards.contains($0) }) {
            excluded.append(you)
        }

        return excluded
    }

    // Body
    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            VStack(spacing: 20) {

                ProgressView(value: Double(step), total: Double(totalSteps - 1))
                    .tint(AppColors.accentRed)

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


//Step Views
extension RoundLogEntryView {

    @ViewBuilder
    var stepView: some View {

        switch step {

        case 0:
            block("Who is making an accusation?") {
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
                block("What card were you shown?") {
                    cardGrid(shownCardOptions, selection: $shownCard)
                }
            } else {
                block("Who showed the card?") {
                    playerGrid(
                        selection: $shownBy,
                        excludedPlayers: excludedShowersForOtherPlayerTurn,
                        allowNone: true
                    )
                }
            }

        case 5:
            block("Who showed you the card?") {
                playerGrid(
                    selection: $shownBy,
                    excludedPlayers: [you]
                )
            }

        default:
            EmptyView()
        }
    }
}


// Block Layout
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


// Player Grid
extension RoundLogEntryView {

    func playerGrid(selection: Binding<String>,
                    excludedPlayers: [String] = [],
                    allowNone: Bool = false) -> some View {

        let availablePlayers = players.filter { !excludedPlayers.contains($0) }
        let options = allowNone ? availablePlayers + ["None"] : availablePlayers

        return LazyVGrid(columns: [.init(.adaptive(minimum: 120))], spacing: 12) {

            ForEach(options, id: \.self) { name in

                Button {
                    AppFeedback.tap()
                    selection.wrappedValue = name
                } label: {
                    HStack {
                        Text(name)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)

                        Spacer()

                        if name == you && selection.wrappedValue == name {
                            Text("You")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.3))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(
                        selection.wrappedValue == name
                        ? playerColor(name)
                        : AppColors.cardBackgroundStrong
                    )
                    .cornerRadius(12)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}


// Card Grid
extension RoundLogEntryView {

    func cardGrid(_ items: [String],
                  selection: Binding<String>) -> some View {

        LazyVGrid(columns: [.init(.adaptive(minimum: 96))], spacing: 12) {

            ForEach(items, id: \.self) { item in

                let selected = selection.wrappedValue == item

                Button {
                    AppFeedback.tap()
                    selection.wrappedValue = item
                    if item == "None" {
                        shownBy = ""
                    }
                } label: {
                    Text(item)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            selected
                            ? colorForCard(item)
                            : AppColors.cardBackgroundStrong
                        )
                        .cornerRadius(12)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
    }
}


// Navigation
extension RoundLogEntryView {

    var navButtons: some View {
        HStack {

            if step > 0 {
                Button("Back") { step -= 1 }
                    .foregroundColor(.white)
                    .contentShape(Rectangle())
                    .buttonStyle(PressableButtonStyle())
            }

            Spacer()

            Button(step == totalSteps - 1 ? "Save" : "Next") {

                if step == totalSteps - 1 {
                    AppFeedback.success()
                    save()
                } else {
                    AppFeedback.tap()
                    step += 1
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 12)
            .background(canContinue ? AppColors.accentRed : Color.gray)
            .cornerRadius(14)
            .disabled(!canContinue)
            .contentShape(Rectangle())
            .buttonStyle(PressableButtonStyle())
        }
    }
}


// Logic
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
                : !shownBy.isEmpty
        case 5:
            return !shownBy.isEmpty
        default:
            return false
        }
    }

    func save() {
        // "None" is stored as nil so downstream logic can treat unanswered accusations
        // and hidden-card shows consistently.
        let log = RoundLog(
            player: selectedPlayer,
            suspect: suspect,
            weapon: weapon,
            room: room,
            shownBy: shownCard == "None" ? nil : (shownBy == "None" ? nil : shownBy),
            shownCard: (shownCard.isEmpty || shownCard == "None") ? nil : shownCard
        )

        onSave(log)
    }

    func playerColor(_ name: String) -> Color {
        if name == "None" {
            return AppColors.accentRed
        }

        let index = players.firstIndex(of: name) ?? 0
        let colors: [Color] = [.blue, .green, AppColors.accentRed, .yellow, .purple, .orange]
        return colors[index % colors.count]
    }

    func colorForCard(_ card: String) -> Color {
        if weapons.contains(card) {
            return .orange
        } else if rooms.contains(card) {
            return .blue
        } else {
            return AppColors.accentRed
        }
    }
}
