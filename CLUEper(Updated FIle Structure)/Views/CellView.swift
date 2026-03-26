import SwiftUI

struct CellView: View {

    let state: CellState

    var body: some View {

        ZStack {

            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.gray)
                .frame(width: 28, height: 28)

            switch state {

            case .has:
                Text("✓")

            case .no:
                Text("✕")

            case .maybe:
                Text("?")

            case .unknown:
                EmptyView()
            }
        }
    }
}
