import SwiftUI

struct DiscardPileView: View {
    let discards: [MahjongTile]
    
    let columns = [
        GridItem(.adaptive(minimum: 25, maximum: 30), spacing: 2)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(discards) { tile in
                TileView(tile: tile, size: CGSize(width: 25, height: 35))
            }
        }
        .padding()
        .background(Color.black.opacity(0.05))
        .cornerRadius(10)
        .frame(minHeight: 150)
    }
}
