import SwiftUI

struct RootView: View {
    @StateObject private var savedGamesStore = SavedGamesStore()
    @State private var activeGame: SavedGame?
    @State private var showingNewGameFlow = false
    @State private var showingGuide = false

    var body: some View {
        // Root routing is intentionally state-driven instead of using a navigation stack.
        // The app always lives in one of three modes: welcome, setup, or active game.
        Group {
            if let currentGame = activeGame {
                DetectiveNotesView(
                    game: currentGame,
                    onSave: { updatedGame in
                        savedGamesStore.save(updatedGame)
                        self.activeGame = updatedGame
                    },
                    onHome: {
                        activeGame = nil
                        showingNewGameFlow = false
                    }
                )
            } else if showingNewGameFlow {
                NewGameFlowView(
                    onStartGame: { game in
                        activeGame = game
                        showingNewGameFlow = false
                    },
                    onCancel: {
                        showingNewGameFlow = false
                    }
                )
            } else {
                WelcomeView(
                    savedGames: savedGamesStore.games,
                    onShowGuide: {
                        showingGuide = true
                    },
                    onNewGame: {
                        showingNewGameFlow = true
                    },
                    onResumeGame: { game in
                        activeGame = game
                    },
                    onDeleteGame: { game in
                        savedGamesStore.delete(game)
                    }
                )
            }
        }
        .sheet(isPresented: $showingGuide) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        guideSection(
                            title: "Getting Started",
                            items: [
                                "Create a game by entering the player count, choosing yourself, and selecting your cards.",
                                "Blank player names fall back to Clue-style character names."
                            ]
                        )

                        guideSection(
                            title: "Notes Tab",
                            items: [
                                "Tap cells to manually mark yes, no, maybe, or unknown.",
                                "Manual edits are useful when table information becomes public outside the formal turn flow."
                            ]
                        )

                        guideSection(
                            title: "Analysis Tab",
                            items: [
                                "Envelope probabilities estimate which suspect, weapon, and room are most likely in the middle.",
                                "Player Status estimates which opponents are becoming dangerous based on what they could know."
                            ]
                        )

                        guideSection(
                            title: "Log Tab",
                            items: [
                                "Use +Log to record each accusation and any card show.",
                                "You can delete the most recent round if you entered the last one incorrectly."
                            ]
                        )
                    }
                    .padding()
                }
                .background(AppColors.appBackground.ignoresSafeArea())
                .navigationTitle("How To Use CLUEper")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            showingGuide = false
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    func guideSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 7))
                        .foregroundColor(AppColors.accentRed)
                        .padding(.top, 6)

                    Text(item)
                        .foregroundColor(AppColors.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .appCardStyle(cornerRadius: 16)
    }
}
