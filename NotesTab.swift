import SwiftUI

// MARK: - Tabs
enum NotesTab {
    case notes
    case analysis
    case log
}

// MARK: - NOTES TAB (GRID)
extension DetectiveNotesView {

    var roundView: some View {
        VStack(spacing: 0) {
            columnHeader

            ScrollView {
                VStack(spacing: 22) {
                    section(title: "SUSPECTS", rows: $suspects)
                    section(title: "WEAPONS", rows: $weapons)
                    section(title: "ROOMS", rows: $rooms)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - ANALYSIS TAB
extension DetectiveNotesView {

    var analysisView: some View {
        AnalysisRowView(
            result: analysisResult,
            players: players,
            playerStatuses: PlayerStatusEngine.assess(
                players: players,
                yourPlayerName: players[yourPlayerIndex],
                logs: logs,
                suspects: suspects,
                weapons: weapons,
                rooms: rooms
            )
        )
    }
}

// MARK: - LOG TAB
extension DetectiveNotesView {

    var logView: some View {
        LogView(logs: logs, players: players, onDeleteLastLog: {
            AppFeedback.warning()
            let previousGrid = currentGrid()
            _ = logs.popLast()
            refreshGameState(previousGrid: previousGrid)
        })
    }
}
