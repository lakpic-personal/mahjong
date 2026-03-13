import SwiftUI

struct HandView: View {
    @ObservedObject var game: MahjongGame
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(game.activeTiles.prefix(13)) { tile in
                TileView(tile: tile, isFree: game.isFree(tile), size: CGSize(width: 25, height: 35))
            }
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(10)
    }
}
