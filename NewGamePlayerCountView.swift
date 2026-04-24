import SwiftUI

struct NewGamePlayerCountView: View {

    @Binding var players: [Player]
    let onCancel: () -> Void
    let onContinue: () -> Void

    @State private var count: Int = 5
    
    let colors: [Color] = [.blue, .green, AppColors.accentRed, .yellow, .purple, .orange]
    let placeholderNames = [
        "Mrs. Peacock",
        "Mr. Green",
        "Miss Scarlet",
        "Col. Mustard",
        "Prof. Plum",
        "Mrs. White"
    ]

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("How many players?")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("Choose between 3 and 6 players.")
                    .foregroundColor(AppColors.mutedText)

                // Player count stepper
                HStack {
                    Button {
                        AppFeedback.tap()
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
                            .background(AppColors.cardBackgroundStrong)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PressableButtonStyle())

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
                        AppFeedback.tap()
                        if count < 6 {
                            count += 1
                            players.append(
                                Player(
                                    name: "",
                                    color: colors[count - 1]
                                )
                            )
                        }
                    } label: {
                        Text("+")
                            .font(.title)
                            .frame(width: 44, height: 44)
                            .background(AppColors.cardBackgroundStrong)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PressableButtonStyle())
                }

                // Players list
                VStack(spacing: 12) {
                    ForEach(players.indices, id: \.self) { index in
                        HStack(spacing: 12) {

                            Circle()
                                .fill(players[index].color)
                                .frame(width: 12, height: 12)

                            TextField(
                                "",
                                text: $players[index].name,
                                prompt: Text(placeholderNames[index])
                                    .foregroundColor(.white.opacity(0.4))
                            )
                            .foregroundColor(.white)
                            .accentColor(.white)
                        }
                        .padding()
                        .appCardStyle(cornerRadius: 14)
                    }
                }

                Spacer()

                HStack(spacing: 16) {
                    Button("Back") {
                        AppFeedback.tap()
                        onCancel()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .contentShape(Rectangle())
                    .buttonStyle(PressableButtonStyle())

                    Button("Continue") {
                        AppFeedback.tap()
                        continueWithDefaults()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.accentRed)
                    .foregroundColor(.black)
                    .cornerRadius(14)
                    .contentShape(Rectangle())
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding()
        }
        .onAppear {
            if players.isEmpty {
                players = (0..<count).map {
                    Player(
                        name: "",
                        color: colors[$0]
                    )
                }
            }
        }
    }

    private func continueWithDefaults() {
        for index in players.indices {
            let trimmedName = players[index].name.trimmingCharacters(in: .whitespacesAndNewlines)
            players[index].name = trimmedName.isEmpty ? placeholderNames[index] : trimmedName
        }

        onContinue()
    }
}
