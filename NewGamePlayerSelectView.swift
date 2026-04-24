import Foundation
import SwiftUI

struct NewGamePlayerSelectView: View {
    let players: [Player]
    @Binding var selectedPlayerIndex: Int?
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Text("Which player are you?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("Select yourself from the list")
                .foregroundColor(AppColors.mutedText)

            VStack(spacing: 12) {
                ForEach(players.indices, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(players[index].color)
                            .frame(width: 14, height: 14)

                        Text(players[index].name)
                            .fontWeight(.medium)
                            .foregroundColor(.white)

                        Spacer()

                        if selectedPlayerIndex == index {
                            Text("You")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.accentRed)
                                .foregroundColor(.black)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .appCardStyle(cornerRadius: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedPlayerIndex == index ? AppColors.accentRed : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .onTapGesture {
                        AppFeedback.tap()
                        selectedPlayerIndex = index
                    }
                    
                    //Hides Navigation Link Back Button & Disables it
                    .navigationBarBackButtonHidden(true)
                    .interactiveDismissDisabled(true)
                }
            }

            Spacer()

            HStack {
                Button("Back") {
                    AppFeedback.tap()
                    onBack()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.1))
                .foregroundColor(.white)
                .cornerRadius(12)
                .contentShape(Rectangle())
                .buttonStyle(PressableButtonStyle())

                Button("Continue") {
                    AppFeedback.tap()
                    onContinue()
                }
                .disabled(selectedPlayerIndex == nil)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedPlayerIndex == nil ? Color.gray : AppColors.accentRed)
                .foregroundColor(.black)
                .cornerRadius(12)
                .contentShape(Rectangle())
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.appBackground)
    }
}
