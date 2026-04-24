import SwiftUI

// Renders the full analysis screen for the current game state.
struct AnalysisRowView: View {
    // Aggregated probability output for suspects, weapons, and rooms.
    let result: AnalysisResult

    // Ordered player names used to assign consistent colors.
    let players: [String]

    // Per-player deduction progress shown in the status card.
    let playerStatuses: [PlayerStatusEngine.ThreatStatus]

    // Builds the full analysis tab stack.
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Probability breakdown for every card category.
                probabilityContent

                // Summary of the strongest accusation to make next.
                bestAccusationCard

                // Progress snapshot for each opposing player.
                playerStatusCard
            }
            .padding()
        }
        .background(AppColors.appBackground)
    }
}

//Best Accusation Card
extension AnalysisRowView {
    // Shows the most likely suspect, weapon, and room summary.
    var bestAccusationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Card header with supporting icon.
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .padding(8)
                    .background(Color.yellow.opacity(0.15))
                    .cornerRadius(10)
                
                Text("Best Accusation to Make")
                    .foregroundColor(.white)
                    .font(.headline)
            }

            // Explains what the summary represents.
            Text("Most likely correct combination based on your notes")
                .foregroundColor(.white.opacity(0.6))
                .font(.caption)
            
            // Highest-probability suspect.
            accusationRow(title: "Suspect",
                          value: top(result.suspects),
                          color: AppColors.accentRed)

            // Highest-probability weapon.
            accusationRow(title: "Weapon",
                          value: top(result.weapons),
                          color: .orange)

            // Highest-probability room.
            accusationRow(title: "Room",
                          value: top(result.rooms),
                          color: .blue)
        }
        .padding()
        .appCardStyle()
    }
    
    // Renders a single row inside the best-accusation summary card.
    func accusationRow(title: String, value: String, color: Color) -> some View {
        HStack {
            // Category label, like Suspect or Room.
            Text(title)
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            // The selected best match for the category.
            Text(value)
                .foregroundColor(color)
                .fontWeight(.semibold)
        }
        .padding()
        .appCardStyle(cornerRadius: 14)
    }
}

// MARK: - Player Status Card
extension AnalysisRowView {
    // Shows the current threat/progress summary for each opponent.
    var playerStatusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Card header with supporting icon.
            HStack(spacing: 10) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(10)
                
                Text("Player Status")
                    .foregroundColor(.white)
                    .font(.headline)
            }

            // Explains how to interpret the status rows.
            Text("How close each opponent is to knowing the answer")
                .foregroundColor(.white.opacity(0.6))
                .font(.caption)

            // One status row per tracked opponent.
            ForEach(playerStatuses, id: \.name) { player in
                playerRow(player)
            }
        }
        .padding()
        .appCardStyle()
    }
    
    // Renders a single player row with name, label, bar, and detail text.
    func playerRow(_ player: PlayerStatusEngine.ThreatStatus) -> some View {
        // Keeps a player's color stable by using their original seat/order.
        let playerIndex = players.firstIndex(of: player.name) ?? 0

        // Maps deduction progress into a warning color for the row.
        let threatColor = threatColor(for: player.progress)

        return VStack(alignment: .leading, spacing: 6) {
            // Player name and summarized threat pill.
            HStack {
                Text(player.name)
                    .foregroundColor(color(for: playerIndex))

                Spacer()

                Text(player.label)
                    .foregroundColor(threatColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(threatColor.opacity(0.2))
                    .cornerRadius(10)
            }

            // Visual progress bar showing how close the player is.
            GeometryReader { geo in
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        Capsule()
                            .fill(threatColor)
                            .frame(width: geo.size.width * player.progress),
                        alignment: .leading
                    )
            }
            .frame(height: 6)

            // Secondary explanation for why the player has this status.
            Text(player.detail)
                .foregroundColor(.white.opacity(0.5))
                .font(.caption2)
        }
    }
}

// Probability Card
extension AnalysisRowView {
    // Shows per-card envelope probabilities grouped by category.
    var probabilityContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header with title and supporting description.
            HStack(spacing: 10) {
                Image(systemName: "envelope.open.fill")
                    .foregroundColor(.purple)
                    .padding(8)
                    .background(Color.purple.opacity(0.15))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Probabilities")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Likelihood each card is in the envelope")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.caption)
                }
            }

            // Category sections are split out so each group is easy to scan.
            VStack(spacing: 18) {
                probabilitySection(
                    title: "SUSPECTS",
                    data: result.suspects,
                    color: AppColors.accentRed
                )
                
                probabilitySection(
                    title: "WEAPONS",
                    data: result.weapons,
                    color: .orange
                )
                
                probabilitySection(
                    title: "ROOMS",
                    data: result.rooms,
                    color: .blue
                )
            }
        }
        .padding()
        .appCardStyle()
    }
    
    // Builds one category block of probability bars.
    func probabilitySection(title: String,
                            data: [String: Double],
                            color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category heading styled to match its accent color.
            Text(title)
                .foregroundColor(color)
                .font(.caption.bold())
                .opacity(0.9)

            // Each row shows a card name, its probability bar, and percent.
            ForEach(sortedKeys(data), id: \.self) { key in
                // Pulls the probability for the current card key.
                let value = data[key] ?? 0

                HStack {
                    // Card name column.
                    Text(key)
                        .foregroundColor(.white)
                        .frame(width: 120, alignment: .leading)

                    // Horizontal bar scaled to the card's probability.
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            // Background track.
                            Capsule()
                                .fill(Color.white.opacity(0.1))

                            // Foreground fill.
                            Capsule()
                                .fill(color)
                                .frame(width: geo.size.width * value)
                        }
                    }
                    .frame(height: 8)

                    // Numeric percentage for exact reading.
                    Text("\(Int(value * 100))%")
                        .foregroundColor(color)
                        .font(.caption.monospacedDigit().weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .frame(width: 52, alignment: .trailing)
                }
                .padding(10)
                .appCardStyle(cornerRadius: 10)
            }
        }
    }
    
    // Keeps probability rows ordered consistently.
    func sortedKeys(_ dict: [String: Double]) -> [String] {
        dict.keys.sorted()
    }
}

// MARK: - Helpers
extension AnalysisRowView {
    // Returns the highest-probability card name in a category.
    func top(_ dict: [String: Double]) -> String {
        dict.max(by: { $0.value < $1.value })?.key ?? "-"
    }

    // Maps a progress value to the threat label shown in the UI.
    func threatLabel(for progress: Double) -> String {
        switch progress {
        case 0.75...:
            return "High Threat"
        case 0.4..<0.75:
            return "Medium Threat"
        default:
            return "Low Threat"
        }
    }

    // Maps a progress value to the threat color shown in the UI.
    func threatColor(for progress: Double) -> Color {
        switch progress {
        case 0.75...:
            return AppColors.accentRed
        case 0.4..<0.75:
            return .orange
        default:
            return .green
        }
    }

    // Reuses the app-wide player color order for names in the status card.
    func color(for playerIndex: Int) -> Color {
        // The palette mirrors the rest of the app's player color mapping.
        let colors: [Color] = [.blue, .green, AppColors.accentRed, .yellow, .purple, .orange]
        return colors[playerIndex % colors.count]
    }
}
