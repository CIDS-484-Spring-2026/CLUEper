//
//  NewGameFlowView.swift
//  CLUEper
//
//  Created by Elijah William Belz on 2/5/26.
//

import SwiftUI

struct NewGameFlowView: View {

    enum Step: Int, CaseIterable {
        case playerCount
        case playerSelect
        case cardSelect
    }

    @State private var step: Step = .playerCount
    @State private var players: [Player] = []
    @State private var selectedPlayerIndex: Int? = nil

    var body: some View {
        VStack {
            ProgressBar(step: step)

            switch step {

            case .playerCount:
                NewGamePlayerCountView(
                    players: $players,
                    onContinue: {
                        step = .playerSelect
                    }
                )

            case .playerSelect:
                NewGamePlayerSelectView(
                    players: players,
                    selectedPlayerIndex: $selectedPlayerIndex,
                    onBack: {
                        step = .playerCount
                    },
                    onContinue: {
                        step = .cardSelect
                    }
                )

            case .cardSelect:
                NewGameCardSelectView(
                    players: players,
                    selectedPlayerIndex: selectedPlayerIndex,
                    onBack: {
                        step = .playerSelect
                    }
                )
            }
        }
        .navigationTitle("New Game")
        .navigationBarTitleDisplayMode(.inline)
    }
}
