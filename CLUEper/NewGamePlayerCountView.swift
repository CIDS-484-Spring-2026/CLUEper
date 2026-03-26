import SwiftUI

/// Step 1: Choose number of players + edit names
struct NewGamePlayerCountView: View {
    
    @Binding var players: [Player]
    let onContinue: () -> Void

    @State private var count: Int = 5

    /// Color assigned per player
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {

                Text("How many players?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Clue supports 3–6 players")
                    .foregroundColor(.white.opacity(0.6))

                // +/- player count control
                HStack {
                    Button {
                        if count > 3 {
                            count -= 1
                            if !players.isEmpty {
                                players.removeLast()
                            }
                        }
                    } label: { Text("−") }

                    Spacer()

                    VStack {
                        Text("\(count)").font(.system(size: 42, weight: .bold))
                        Text("players").font(.caption)
                    }

                    Spacer()

                    Button {
                        if count < 6 {
                            count += 1
                            players.append(
                                Player(
                                    name: "Player \(count)",
                                    color: colors[count - 1]
                                )
                            )
                        }
                    } label: { Text("+") }
                }

                // Editable player names
                VStack {
                    ForEach(players.indices, id: \.self) { index in
                        TextField(
                            "Player \(index + 1)",
                            text: $players[index].name
                        )
                    }
                }

                Spacer()

                // Continue only if all names filled
                Button("Continue") {
                    onContinue()
                }
                .disabled(players.contains {
                    $0.name.trimmingCharacters(in: .whitespaces).isEmpty
                })
            }
            .padding()
        }
        .onAppear {
            // Initialize default players
            if players.isEmpty {
                players = (0..<count).map {
                    Player(
                        name: "Player \($0 + 1)",
                        color: colors[$0]
                    )
                }
            }
        }
    }
}