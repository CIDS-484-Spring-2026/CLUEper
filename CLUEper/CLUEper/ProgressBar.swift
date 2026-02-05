//
//  ProgressBar.swift
//  CLUEper
//
//  Created by Elijah William Belz on 2/5/26.
//

import Foundation
import SwiftUI

struct ProgressBar: View {
    let step: NewGameFlowView.Step

    var body: some View {
        HStack(spacing: 8) {
            ForEach(NewGameFlowView.Step.allCases, id: \.self) { current in
                Capsule()
                    .fill(current.rawValue <= step.rawValue ? Color.red : Color.gray.opacity(0.4))
                    .frame(height: 4)
            }
        }
        .padding()
    }
}
