import SwiftUI

//Main View
struct DetectiveNotesView: View {
    private let initialGame: SavedGame
    let onSave: (SavedGame) -> Void
    let onHome: () -> Void

    let players: [String]
    let yourCards: [String]
    let yourPlayerIndex: Int

    @State private var didSave = false
    @State var analysisResult = AnalysisResult.empty

    @State var rooms: [CardRow] = []
    @State var suspects: [CardRow] = []
    @State var weapons: [CardRow] = []
    @State var logs: [RoundLog]
    @State var selectedTab: NotesTab = .notes

    @State var showingAddLog = false
    @State private var highlightedCells: Set<String> = []

    init(
        game: SavedGame,
        onSave: @escaping (SavedGame) -> Void,
        onHome: @escaping () -> Void
    ) {
        self.initialGame = game
        self.onSave = onSave
        self.onHome = onHome
        self.players = game.players
        self.yourCards = game.yourCards
        self.yourPlayerIndex = game.yourPlayerIndex
        _logs = State(initialValue: game.logs)
    }

    var body: some View {
        ZStack {

            AppColors.appBackground
                .ignoresSafeArea()
                .navigationBarHidden(true)

            VStack(spacing: 0) {

                header

                Group {
                    switch selectedTab {
                    case .notes:
                        roundView
                    case .analysis:
                        analysisView
                    case .log:
                        logView
                    }
                }

                Spacer(minLength: 6)

                if selectedTab == .notes {
                    legend
                        .padding(.vertical, 8)
                }
            }

            if showingAddLog {
                ZStack {
                    AppColors.overlay
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingAddLog = false
                        }

                    VStack {
                        Spacer()

                        VStack(spacing: 12) {

                            Capsule()
                                .frame(width: 40, height: 5)
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 8)

                            RoundLogEntryView(
                                players: players,
                                you: players[yourPlayerIndex],
                                yourCards: yourCards
                            ) { newLog in
                                AppFeedback.success()
                                logs.append(newLog)
                                refreshGameState(previousGrid: currentGrid())
                                showingAddLog = false
                            }
                        }
                        .frame(height: 350)
                        .padding(.bottom, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.94))
                        )
                        .cornerRadius(20)
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
                .animation(.easeInOut, value: showingAddLog)
            }
        }
        .onAppear { refreshGameState() }
    }
}

// MARK: - Sections / Grid
extension DetectiveNotesView {

    func section(title: String, rows: Binding<[CardRow]>) -> some View {
        VStack(spacing: 14) {

            HStack {
                Rectangle().fill(Color.white.opacity(0.25)).frame(height: 1)

                Text(title)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.caption.bold())
                    .padding(.horizontal, 8)

                Rectangle().fill(Color.white.opacity(0.25)).frame(height: 1)
            }
            .padding(.horizontal, 6)

            ForEach(rows) { $row in
                rowView($row)
            }
        }
    }

    func rowView(_ row: Binding<CardRow>) -> some View {
        GeometryReader { geo in

            let nameWidth = geo.size.width * 0.28
            let cellWidth = (geo.size.width - nameWidth - 4) / CGFloat(players.count)

            HStack(spacing: 0) {

                Text(row.wrappedValue.name)
                    .foregroundColor(.white)
                    .frame(width: nameWidth, alignment: .leading)

                ForEach(row.wrappedValue.states.indices, id: \.self) { index in
                    cellView(
                        cardName: row.wrappedValue.name,
                        playerIndex: index,
                        state: row.wrappedValue.states[index]
                    )
                        .frame(width: cellWidth)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            AppFeedback.tap()
                            row.wrappedValue.states[index] = DeductionEngine.nextState(
                                row.wrappedValue.states[index]
                            )
                        }
                }
            }
        }
        .frame(height: 42)
    }
}

// MARK: - Cell
extension DetectiveNotesView {

    func cellView(cardName: String, playerIndex: Int, state: CellState) -> some View {
        let isHighlighted = highlightedCells.contains(highlightKey(cardName: cardName, playerIndex: playerIndex))

        return ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(isHighlighted ? Color.white.opacity(0.14) : Color.clear)

            RoundedRectangle(cornerRadius: 5)
                .stroke(isHighlighted ? Color.white.opacity(0.85) : Color.white.opacity(0.35), lineWidth: 1.6)

            switch state {
            case .unknown:
                EmptyView()
            case .has:
                Image(systemName: "checkmark").foregroundColor(.green)
            case .no:
                Image(systemName: "xmark").foregroundColor(AppColors.accentRed)
            case .maybe:
                Text("?").foregroundColor(.yellow)
            }
        }
        .frame(width: 26, height: 26)
    }
}

// MARK: - Header + Tabs
extension DetectiveNotesView {

    var header: some View {
        VStack(spacing: 12) {

            HStack {

                Button {
                    AppFeedback.tap()
                    onHome()
                } label: {
                    Image(systemName: "house.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())

                Spacer()

                HStack(spacing: 6) {
                    Text("CLUEper")
                        .font(.system(size: 26, weight: .semibold))

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)

                Spacer()

                Button {
                    saveCurrentGame()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: didSave ? "checkmark.circle.fill" : "externaldrive.fill")
                        Text(didSave ? "Saved" : "Save")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(didSave ? .green : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, 16)

            Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)

            HStack(spacing: 12) {
                tabButton("Notes", icon: "square.grid.2x2", tab: .notes, color: .orange)
                tabButton("Analysis", icon: "brain.head.profile", tab: .analysis, color: .purple)
                tabButton("Log", icon: "list.bullet", tab: .log, color: .gray)

                Button {
                    AppFeedback.tap()
                    showingAddLog = true
                } label: {
                    Text("+Log")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(AppColors.accentRed)
                        .cornerRadius(14)
                        .contentShape(Rectangle())
                }
                .buttonStyle(PressableButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)

            Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
        }
    }

    func tabButton(_ title: String,
                   icon: String,
                   tab: NotesTab,
                   color: Color) -> some View {

        let isSelected = selectedTab == tab

        return Button {
            selectedTab = tab
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(isSelected ? 1 : 0.6))
            .cornerRadius(14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableButtonStyle())
    }
}

// MARK: - Legend
extension DetectiveNotesView {

    var legend: some View {
        HStack(spacing: 20) {
            Text("✔ Yes").foregroundColor(.green)
            Text("✘ No").foregroundColor(AppColors.accentRed)
            Text("? Maybe").foregroundColor(.yellow)
            Text("□ Unknown").foregroundColor(.white)
        }
        .font(.caption2)
    }

    func saveCurrentGame() {
        onSave(currentGameSnapshot())
        AppFeedback.success()
        didSave = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { didSave = false }
        }
    }

    func currentGameSnapshot() -> SavedGame {
        SavedGame(
            id: initialGame.id,
            title: SavedGame.defaultTitle(for: players),
            savedAt: Date(),
            players: players,
            yourCards: yourCards,
            yourPlayerIndex: yourPlayerIndex,
            logs: logs
        )
    }

    func refreshGameState(previousGrid: GameSetupEngine.Grid? = nil) {
        let baseGrid = GameSetupEngine.makeInitialGrid(
            players: players,
            yourCards: yourCards,
            yourPlayerIndex: yourPlayerIndex
        )

        // Analysis can promote some probabilities into hard facts, which then get fed back
        // into deduction so the notes grid and analysis tab stay in sync.
        let analysisOutput = AnalysisEngine.analyze(
            logs: logs,
            players: players,
            yourCards: yourCards,
            yourPlayerName: players[yourPlayerIndex]
        )

        let updatedGrid = DeductionEngine.updateNotesGrid(
            baseGrid: baseGrid,
            logs: logs,
            players: players,
            inferredFacts: analysisOutput.hardFacts
        )

        analysisResult = AnalysisEngine.applyKnownEnvelopeCards(
            from: updatedGrid,
            to: analysisOutput.result
        )

        if let previousGrid {
            highlightedCells = changedCellKeys(from: previousGrid, to: updatedGrid)

            if !highlightedCells.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    highlightedCells = []
                }
            }
        }

        suspects = updatedGrid.suspects
        weapons = updatedGrid.weapons
        rooms = updatedGrid.rooms
    }

    func currentGrid() -> GameSetupEngine.Grid {
        GameSetupEngine.Grid(suspects: suspects, weapons: weapons, rooms: rooms)
    }

    func changedCellKeys(from previousGrid: GameSetupEngine.Grid, to updatedGrid: GameSetupEngine.Grid) -> Set<String> {
        Set(changedCellKeys(in: previousGrid.suspects, updatedRows: updatedGrid.suspects)
            + changedCellKeys(in: previousGrid.weapons, updatedRows: updatedGrid.weapons)
            + changedCellKeys(in: previousGrid.rooms, updatedRows: updatedGrid.rooms))
    }

    func changedCellKeys(in previousRows: [CardRow], updatedRows: [CardRow]) -> [String] {
        zip(previousRows, updatedRows).flatMap { previousRow, updatedRow in
            zip(previousRow.states.indices, zip(previousRow.states, updatedRow.states)).compactMap { index, states in
                states.0 == states.1 ? nil : highlightKey(cardName: updatedRow.name, playerIndex: index)
            }
        }
    }

    func highlightKey(cardName: String, playerIndex: Int) -> String {
        "\(cardName)|\(playerIndex)"
    }
}

// MARK: - Column Header
extension DetectiveNotesView {

    var columnHeader: some View {
        GeometryReader { geo in

            let nameWidth = geo.size.width * 0.28
            let cellWidth = (geo.size.width - nameWidth - 4) / CGFloat(players.count)

            HStack(spacing: 0) {

                Color.clear
                    .frame(width: nameWidth)

                ForEach(players, id: \.self) { name in
                    Text(name)
                        .foregroundColor(playerColor(for: name))
                        .font(.caption.weight(.bold))
                        .frame(width: cellWidth)
                }
            }
        }
        .frame(height: 30)
    }

    func playerColor(for name: String) -> Color {
        let colors: [Color] = [.blue, .green, AppColors.accentRed, .yellow, .purple, .orange]
        if let idx = players.firstIndex(of: name) {
            return colors[idx % colors.count]
        } else {
            return .gray
        }
    }
}
