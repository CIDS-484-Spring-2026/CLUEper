import SwiftUI

struct NotesView: View {

    @EnvironmentObject var vm: GameViewModel

    var body: some View {

        ScrollView {

            section(title: "Suspects", rows: vm.suspects, category: "suspects")
            section(title: "Weapons", rows: vm.weapons, category: "weapons")
            section(title: "Rooms", rows: vm.rooms, category: "rooms")
        }
    }

    func section(title: String, rows: [CardRow], category: String) -> some View {

        VStack(alignment: .leading) {

            Text(title)
                .font(.headline)

            ForEach(rows) { row in

                HStack {

                    Text(row.name)
                        .frame(width: 120, alignment: .leading)

                    ForEach(row.states.indices, id:\.self) { i in

                        CellView(state: row.states[i])
                            .onTapGesture {

                                vm.toggleCell(
                                    category: category,
                                    rowId: row.name,
                                    column: i
                                )
                            }
                    }
                }
            }
        }
        .padding()
    }
}
