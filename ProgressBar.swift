import SwiftUI

/// Visual step indicator for New Game flow
struct ProgressBar: View {
    
    let step: NewGameFlowView.Step

    var body: some View {
        HStack(spacing: 8) {
            
            // One capsule per step
            ForEach(NewGameFlowView.Step.allCases, id: \.self) { current in
                Capsule()
                    .fill(
                        // Fill completed/current steps
                        current.rawValue <= step.rawValue
                        ? AppColors.accentRed
                        : Color.white.opacity(0.2)
                    )
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .background(AppColors.appBackground)
    }
}
