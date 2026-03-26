import SwiftUI

struct NewGamePlayerCountView: View {
    
    @Binding var players: [Player]
    let onContinue: () -> Void

    @State private var count: Int = 5

    let colors: [Color] = [.blue, .green, .red, .yellow, .purple, .orange]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {

                Text("How many players?")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("Clue supports 3–6 players")
                    .foregroundColor(.gray)

                // Player count stepper
                HStack {
                    Button {
                        if count > 3 {
                            count -= 1
                            if !players.isEmpty {
                                players.removeLast()
                            }
                        }
                    } label: {
                        Text("−")
                            .font(.title)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }

                    Spacer()

                    VStack {
                        Text("\(count)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                        Text("players")
                            .foregroundColor(.gray)
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
                    } label: {
                        Text("+")
                            .font(.title)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }

                // Player list (UPDATED STYLE)
                VStack(spacing: 12) {
                    ForEach(players.indices, id: \.self) { index in
                        HStack {
                            Circle()
                                .fill(players[index].color)
                                .frame(width: 10, height: 10)

                            TextField(
                                "Player \(index + 1)",
                                text: $players[index].name
                            )
                            .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                }

                Spacer()

                Button(action: onContinue) {
                    Text("Continue")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.black)
                        .cornerRadius(14)
                }
                .disabled(players.contains {
                    $0.name.trimmingCharacters(in: .whitespaces).isEmpty
                })
                .opacity(players.contains {
                    $0.name.trimmingCharacters(in: .whitespaces).isEmpty
                } ? 0.5 : 1)
            }
            .padding()
        }
        .onAppear {
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
