//
//  LogView.swift
//  CLUEper
//
//  Created by Elijah William Belz on 2/17/26.
//

import Foundation
import SwiftUI

struct LogView: View {
    
    let logs: [RoundLog]
    let players: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing:12){
                ForEach(logs.reversed()) { log in
                    card(log)
                }
            }
            .padding()
        }
    }
    
    
    func card(_ log: RoundLog) -> some View {
        VStack(alignment:.leading, spacing:6){
            
            Text("\(log.player) suggested")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            Text("\(log.suspect) • \(log.weapon) • \(log.room)")
                .foregroundColor(.white)
            
            if let shower = log.shownBy {
                if let shown = log.shownCard {
                    Text("\(shower) showed \(shown)")
                        .foregroundColor(.green)
                        .font(.caption2)
                } else {
                    Text("\(shower) showed a card")
                        .foregroundColor(.yellow)
                        .font(.caption2)
                }
            } else {
                Text("No one could show")
                    .foregroundColor(.red)
                    .font(.caption2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
