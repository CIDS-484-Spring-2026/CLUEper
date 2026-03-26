import SwiftUI

// MARK: - Main View
struct DetectiveNotesView: View {
    
    let players: [String]
    let yourCards: [String]
    let yourPlayerIndex: Int
    
    @State var rooms: [CardRow] = []
    @State var suspects: [CardRow] = []
    @State var weapons: [CardRow] = []
    @State var logs: [RoundLog] = []
    @State var selectedTab: NotesTab = .notes
    
    // Controls visibility of the half-screen logging panel
    @State var showingAddLog = false
    
    var body: some View {
        ZStack {
            
            // Background
            Color.black
                .ignoresSafeArea()
                .navigationBarHidden(true)
            
            // Main content
            VStack(spacing: 0) {
                
                header
                
                Group {
                    switch selectedTab {
                    case .notes: roundView
                    case .ai: aiView
                    case .log: logView
                    }
                }
                
                Spacer(minLength: 6)
                
                legend
                    .padding(.vertical, 8)
            }
            
            // Bottom half logging panel
            if showingAddLog {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        
                        // Drag handle indicator
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.top, 8)
                        
                        // Logging view
                        RoundLogEntryView(
                            players: players,
                            you: players[yourPlayerIndex]
                        ) { newLog in
                            logs.append(newLog)
                            applyLog(newLog)
                            showingAddLog = false
                        }
                    }
                    .frame(height: 350)
                    .padding(.bottom, 20) // adds space above home indicator
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .ignoresSafeArea(edges: .bottom)
                }
                .animation(.easeInOut, value: showingAddLog)
            }
        }
        .onAppear { setupData() }
    }
}

// MARK: - Sections
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
                    .font(.subheadline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(width: nameWidth, alignment: .leading)
                
                ForEach(row.wrappedValue.states.indices, id: \.self) { index in
                    cellView(state: row.wrappedValue.states[index])
                        .frame(width: cellWidth)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            row.wrappedValue.states[index] =
                                row.wrappedValue.states[index].next()
                        }
                }
            }
            .padding(.horizontal, 2)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.white.opacity(0.08)),
                alignment: .bottom
            )
        }
        .frame(height: 42)
    }
}

// MARK: - Cell View
extension DetectiveNotesView {
    
    func cellView(state: CellState) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.white.opacity(0.35), lineWidth: 1.6)
            
            switch state {
            case .unknown: EmptyView()
            case .has: Image(systemName: "checkmark").foregroundColor(.green)
            case .no: Image(systemName: "xmark").foregroundColor(.red)
            case .maybe: Text("?").foregroundColor(.yellow)
            }
        }
        .frame(width: 26, height: 26)
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
                
                ForEach(players.indices, id: \.self) { index in
                    Text(players[index])
                        .foregroundColor(playerColor(for: index))
                        .font(.caption.weight(.bold))
                        .frame(width: cellWidth)
                }
            }
        }
        .frame(height: 30)
    }
    
    func playerColor(for index: Int) -> Color {
        let colors: [Color] = [.red,.blue,.green,.yellow,.purple,.orange]
        return colors[index % colors.count]
    }
}

// MARK: - Header + Tabs
extension DetectiveNotesView {
    
    var header: some View {
        VStack(spacing: 16) {
            
            Text("CLUEper")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .tracking(1.3)
                .padding(.top, 6)

            Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
            
            HStack(spacing: 12) {
                
                tabButton("Notes", icon: "square.grid.2x2", tab: .notes, color: .orange)
                tabButton("AI", icon: "brain", tab: .ai, color: .purple)
                tabButton("Log", icon: "list.bullet", tab: .log, color: .gray)

                Button { showingAddLog = true } label: {
                    pill(text: "+Log", systemImage: nil, color: .red)
                }
            }
            .padding(.horizontal, 10)
            
            Rectangle().fill(Color.white.opacity(0.15)).frame(height: 1)
        }
        .padding(.bottom, 10)
    }
    
    func tabButton(_ title: String,
                   icon: String,
                   tab: NotesTab,
                   color: Color) -> some View {

        let isSelected = selectedTab == tab

        return Button { selectedTab = tab } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(isSelected ? 1 : 0.75))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.black.opacity(0.9) : Color.clear, lineWidth: 2)
            )
            .cornerRadius(14)
        }
    }
}

// MARK: - Legend
extension DetectiveNotesView {
    
    var legend: some View {
        HStack(spacing: 20) {
            legendItem(symbol: "checkmark", color: .green, label: "Yes")
            legendItem(symbol: "xmark", color: .red, label: "No")
            legendItem(text: "?", color: .yellow, label: "Maybe")
            legendItem(square: true, label: "Unknown")
        }
        .font(.caption2)
        .foregroundColor(.white.opacity(0.75))
    }
    
    func legendItem(symbol: String? = nil,
                    text: String? = nil,
                    color: Color = .white,
                    square: Bool = false,
                    label: String) -> some View {
        
        HStack(spacing: 4) {
            if let symbol = symbol { Image(systemName: symbol).foregroundColor(color) }
            if let text = text { Text(text).foregroundColor(color) }
            
            if square {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                    .frame(width: 12, height: 12)
            }
            
            Text(label)
        }
    }
}

// MARK: - Pill Style
extension DetectiveNotesView {
    
    func pill(text: String,
              systemImage: String?,
              color: Color) -> some View {
        
        HStack(spacing: 6) {
            if let systemImage = systemImage { Image(systemName: systemImage) }
            Text(text)
        }
        .font(.system(size: 15, weight: .semibold))
        .foregroundColor(.white)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(color)
        .cornerRadius(14)
    }
}

// MARK: - Data Setup
extension DetectiveNotesView {
    
    func setupData() {
        
        let roomNames = ClueCards.rooms
        let suspectNames = ClueCards.suspects
        let weaponNames = ClueCards.weapons
        
        rooms = roomNames.map { CardRow(name: $0, states: initialStates(for: $0)) }
        suspects = suspectNames.map { CardRow(name: $0, states: initialStates(for: $0)) }
        weapons = weaponNames.map { CardRow(name: $0, states: initialStates(for: $0)) }
    }
    
    func initialStates(for card: String) -> [CellState] {
        players.enumerated().map { index,_ in
            
            if yourCards.contains(card) {
                return index == yourPlayerIndex ? .has : .no
            }
            
            return index == yourPlayerIndex ? .no : .unknown
        }
    }
}

// MARK: - APPLY LOG TO GRID
extension DetectiveNotesView {
    
    func applyLog(_ log: RoundLog) {

        if let shownCard = log.shownCard,
           let playerIndex = players.firstIndex(of: log.shownBy ?? "") {

            update(card: shownCard, playerIndex: playerIndex)
            return
        }

        if let shower = log.shownBy,
           let playerIndex = players.firstIndex(of: shower) {

            markMaybe(card: log.suspect, playerIndex: playerIndex)
            markMaybe(card: log.weapon, playerIndex: playerIndex)
            markMaybe(card: log.room, playerIndex: playerIndex)
        }
    }
    
    func update(card: String, playerIndex: Int) {

        func updateRow(_ rows: inout [CardRow]) -> Bool {
            if let i = rows.firstIndex(where: { $0.name == card }) {

                for index in rows[i].states.indices {
                    rows[i].states[index] = (index == playerIndex) ? .has : .no
                }

                return true
            }
            return false
        }

        if updateRow(&suspects) { return }
        if updateRow(&weapons) { return }
        if updateRow(&rooms) { return }
    }
    
    func markMaybe(card: String, playerIndex: Int) {

        func updateRow(_ rows: inout [CardRow]) -> Bool {
            if let i = rows.firstIndex(where: { $0.name == card }) {

                let current = rows[i].states[playerIndex]

                if current == .unknown {
                    rows[i].states[playerIndex] = .maybe
                }

                return true
            }
            return false
        }

        if updateRow(&suspects) { return }
        if updateRow(&weapons) { return }
        if updateRow(&rooms) { return }
    }
}
