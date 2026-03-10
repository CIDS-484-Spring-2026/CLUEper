import Foundation
import SwiftUI

struct ProgressBar: View {
    let step: NewGameFlowView.Step

    var body: some View {
        
        HStack(spacing: 8) {
            ForEach(NewGameFlowView.Step.allCases, id: \.self) { current in
                Capsule()
                    .fill(
                        current.rawValue <= step.rawValue
                        ? Color.red
                        : Color.white.opacity(0.2)
                    )
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color.black)
        
    }
}
