import SwiftUI

/// Displays list of past round logs
struct LogView: View {
    
    let logs: [RoundLog]
    let players: [String]
    let onDeleteLastLog: (() -> Void)?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if logs.isEmpty {
                    VStack(spacing: 10) {
                        Text("No rounds logged yet")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Tap +Log to record accusations and card shows so the Analysis tab can update probabilities and deductions.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppColors.mutedText)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 24)
                    .appCardStyle()
                } else {
                    ForEach(Array(logs.reversed().enumerated()), id: \.element.id) { index, log in
                        card(log, round: logs.count - index)
                    }
                }
            }
            .padding()
        }
        .background(AppColors.appBackground)
        .alert("Delete Last Round?", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                onDeleteLastLog?()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Only the most recently entered round will be removed.")
        }
    }
}


// MARK: - Card UI
extension LogView {
    func card(_ log: RoundLog, round: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // MARK: Header Row
            HStack(spacing: 10) {
                
                Text("R\(round)")
                    .font(.caption.bold())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                
                Text(log.player)
                    .foregroundColor(playerColor(log.player))
                    .fontWeight(.semibold)
                
                Text("suggested")
                    .foregroundColor(.gray)
                
                Spacer()

                if round == logs.count, onDeleteLastLog != nil {
                    Button {
                        showingDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.white.opacity(0.5))
                            .padding(8)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // MARK: Chips Row
            HStack(spacing: 10) {
                chip(log.suspect)
                chip(log.weapon)
                chip(log.room)
            }
            
            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
            
            // MARK: Result Row
            resultView(log)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.08),
                    Color.white.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.08))
        )
        .cornerRadius(18)
        .contentShape(RoundedRectangle(cornerRadius: 18))
    }
}


// MARK: - Chips
extension LogView {
    
    func chip(_ text: String) -> some View {
        let color = colorForCard(text)
        
        return Text(text)
            .font(.caption.weight(.medium))
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.6), lineWidth: 1)
            )
            .clipShape(Capsule())
    }
}


// MARK: - Result Row
extension LogView {
    
    @ViewBuilder
    func resultView(_ log: RoundLog) -> some View {
        
        if let shower = log.shownBy {
            
            if let shown = log.shownCard {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text("\(shower) showed \(shown)")
                        .foregroundColor(.green)
                }
            } else {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 8, height: 8)
                    
                    Text("\(shower) showed a card")
                        .foregroundColor(.yellow)
                }
            }
            
        } else {
            HStack(spacing: 8) {
                Circle()
                    .fill(AppColors.accentRed)
                    .frame(width: 8, height: 8)
                
                Text("Nobody could show")
                    .foregroundColor(AppColors.accentRed)
            }
        }
    }
}


// MARK: - Color Logic (Consistent with App)
extension LogView {
    
    func colorForCard(_ card: String) -> Color {
        if ClueCards.weapons.contains(card) {
            return .orange
        } else if ClueCards.rooms.contains(card) {
            return .blue
        } else {
            return AppColors.accentRed
        }
    }
    
    func playerColor(_ name: String) -> Color {
        let index = players.firstIndex(of: name) ?? 0
        let colors: [Color] = [.blue, .green, AppColors.accentRed, .yellow, .purple, .orange]
        return colors[index % colors.count]
    }
}
