import SwiftUI

/// Entry screen of the app.
/// Shows branding, saved games, and navigation into the setup flow.
struct WelcomeView: View {
    let savedGames: [SavedGame]
    let onShowGuide: () -> Void
    let onNewGame: () -> Void
    let onResumeGame: (SavedGame) -> Void
    let onDeleteGame: (SavedGame) -> Void
    @State private var pendingDelete: SavedGame?

    var body: some View {
        ZStack {
            Image("Start_Screen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [Color.black.opacity(0.2), Color.black.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 8) {
                    HStack {
                        Button {
                            AppFeedback.tap()
                            onShowGuide()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "lightbulb.2.fill")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.black)
                                    .symbolRenderingMode(.hierarchical)

                                Text("Help")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            .padding(.leading, 2)
                        }
                        .buttonStyle(PressableButtonStyle())

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, -6)

                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 90, weight: .bold))
                        .foregroundColor(.black)

                    Text("CLUEper")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.black)

                    if !savedGames.isEmpty {
                        savedGamesSection
                    } else {
                        emptyStateCard
                    }

                    Button {
                        AppFeedback.tap()
                        onNewGame()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                            Text("New Game")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .frame(height: 62)
                        .frame(maxWidth: 360)
                        .background(AppColors.accentRed)
                        .foregroundColor(.black)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.black, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PressableButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: 360)
                .padding(.horizontal, 28)

                Spacer()

                MarqueeText(
                    text: "Track suspects, weapons, and rooms as you solve the mystery. Never run out of notecards again!",
                    font: .footnote,
                    speed: 70
                )
                .frame(height: 20)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(14)
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Delete Saved Game?", isPresented: deleteAlertBinding) {
            Button("Delete", role: .destructive) {
                if let game = pendingDelete {
                    AppFeedback.warning()
                    onDeleteGame(game)
                    pendingDelete = nil
                }
            }
            Button("Cancel", role: .cancel) {
                pendingDelete = nil
            }
        } message: {
            Text("This save will be removed from the start screen.")
        }
    }
}

private extension WelcomeView {
    var deleteAlertBinding: Binding<Bool> {
        Binding(
            get: { pendingDelete != nil },
            set: { isPresented in
                if !isPresented {
                    pendingDelete = nil
                }
            }
        )
    }

    var savedGamesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Saved Games")
                .font(.system(size: 13, weight: .semibold))
                .textCase(.uppercase)
                .foregroundColor(AppColors.mutedText)

            if savedGames.count <= 2 {
                VStack(spacing: 8) {
                    ForEach(savedGames) { game in
                        savedGameCard(game)
                    }
                }
            } else if !savedGames.isEmpty {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(savedGames) { game in
                            savedGameCard(game)
                        }
                    }
                }
                .frame(maxHeight: 180)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var emptyStateCard: some View {
        VStack(spacing: 10) {
            Text("No saved games yet")
                .font(.headline)
                .foregroundColor(.white)

            Text("Start a new case and your progress will appear here.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.mutedText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .padding(.horizontal, 18)
        .appCardStyle()
    }

    func savedGameCard(_ game: SavedGame) -> some View {
        Button {
            AppFeedback.tap()
            onResumeGame(game)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "play.circle")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(red: 0.30, green: 0.86, blue: 0.48))

                VStack(alignment: .leading, spacing: 4) {
                    Text(game.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(savedGameSubtitle(for: game))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.mutedText)
                }

                Spacer(minLength: 8)

                Button {
                    pendingDelete = game
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.white.opacity(0.38))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(cardBackground)
            .overlay(cardBorder)
            .cornerRadius(18)
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(PressableButtonStyle())
    }

    var cardBackground: some ShapeStyle {
        Color.black.opacity(0.24)
    }

    var cardBorder: some View {
        RoundedRectangle(cornerRadius: 18)
            .stroke(Color.white.opacity(0.14), lineWidth: 1)
    }

    func savedGameSubtitle(for game: SavedGame) -> String {
        let date = game.savedAt.formatted(.dateTime.month(.abbreviated).day())
        let rounds = game.logs.count == 1 ? "1 round" : "\(game.logs.count) rounds"
        return "\(date) • \(rounds)"
    }
}

struct Previews_WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(
            savedGames: [],
            onShowGuide: {},
            onNewGame: {},
            onResumeGame: { _ in },
            onDeleteGame: { _ in }
        )
    }
}
