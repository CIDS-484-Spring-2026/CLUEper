//
//  RootView.swift
//  CLUEper
//
//  Created by Elijah William Belz on 2/3/26.
//

import Foundation
import SwiftUI

struct RootView: View {
    @State private var hasStartedGame = false

    var body: some View {
        Group {
            if hasStartedGame {
                HomeView()
            } else {
                WelcomeView()
            }
        }
    }
}

