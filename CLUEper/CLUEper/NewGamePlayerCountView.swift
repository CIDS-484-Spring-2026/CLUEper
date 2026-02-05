//
//  NewGamePlayerCountView.swift
//  CLUEper
//
//  Created by Elijah William Belz on 2/5/26.
//

import SwiftUI

struct NewGamePlayerCountView: View {
    @Binding var players: [Player]
    let onContinue: () -> Void

    @State private var count: Int = 5

    let colors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .orange
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            // Title
            Text("How many players?")
                .font(.title2)
                .fontWeight(.bold)

            Text("Clue supports 3–6 players")
                .foregroundColor(.secondary)

            // Counter
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
                        .font(.system(size: 28, weight: .bold))
                        .frame(width: 44, height: 44)
                }

                Spacer()

                VStack {
                    Text("\(count)")
                        .font(.system(size: 42, weight: .bold))
                    Text("players")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                        .font(.system(size: 28, weight: .bold))
                        .frame(width: 44, height: 44)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.3))
            )

            // Player list with name editing
            VStack(spacing: 12) {
                ForEach(players.indices, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(players[index].color)
                            .frame(width: 14, height: 14)

                        TextField(
                            "Player \(index + 1)",
                            text: $players[index].name
                        )
                        .textFieldStyle(.roundedBorder)
                    }
                }
            }

            Spacer()

            // Continue button
            Button("Continue") {
                onContinue()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(16)
            .disabled(
                players.contains {
                    $0.name.trimmingCharacters(in: .whitespaces).isEmpty
                }
            )
        }
        .padding()
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
