import SwiftUI

enum NotesTab {
    case notes
    case ai
    case log
}
//ROUND TAB
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

//AI TAB
extension DetectiveNotesView {
    
    var aiView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain")
                .font(.system(size: 42))
                .foregroundColor(.purple)
            
            Text("AI Assistant Coming Soon")
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxHeight: .infinity)
    }
}

//LOG TAB
extension DetectiveNotesView {
    
    var logView: some View {
        LogView(logs: logs, players: players)
    }
}
