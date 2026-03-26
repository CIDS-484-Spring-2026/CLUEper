import SwiftUI

/// Step 2: Choose which player is YOU
struct NewGamePlayerSelectView: View {
    
    let players: [Player]
    @Binding var selectedPlayerIndex: Int?
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text("Which player are you?")
                .font(.title2)
                .foregroundColor(.white)

            VStack {
                ForEach(players.indices, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(players[index].color)

                        Text(players[index].name)

                        Spacer()

                        // Highlight selected player
                        if selectedPlayerIndex == index {
                            Text("You")
                        }
                    }
                    .onTapGesture {
                        selectedPlayerIndex = index
                    }
                }
            }

            Spacer()

            HStack {
                Button("Back", action: onBack)

                Button("Continue", action: onContinue)
                    .disabled(selectedPlayerIndex == nil)
            }
        }
    }
}