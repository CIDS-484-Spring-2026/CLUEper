//
//  NewGamePlayerSelectView.swift
//  CLUEper
//
//  Created by Elijah William Belz on 2/5/26.
//

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

            Text("Select yourself from the list")
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                ForEach(players.indices, id: \.self) { index in
                    HStack {
                        Circle()
                            .fill(players[index].color)
                            .frame(width: 14, height: 14)

                        Text(players[index].name)
                            .fontWeight(.medium)

                        Spacer()

                        if selectedPlayerIndex == index {
                            Text("You")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedPlayerIndex == index ? Color.red : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .cornerRadius(12)
                    .onTapGesture {
                        selectedPlayerIndex = index
                    }
                }
            }

            Spacer()

            HStack {
                Button("Back") {
                    onBack()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(12)

                Button("Continue") {
                    onContinue()
                }
                .disabled(selectedPlayerIndex == nil)
                
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }
}
