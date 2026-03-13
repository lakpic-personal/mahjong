import SwiftUI

struct WallView: View {
    let count: Int
    
    var body: some View {
        VStack {
            Text("Remaining: \(count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 2) {
                ForEach(0..<min(count / 2, 10), id: \.self) { _ in
                    VStack(spacing: -15) {
                        TileView(tile: MahjongTile(id: UUID(), type: .wind(.east), position: BoardPosition(x: 0, y: 0, z: 0)), size: CGSize(width: 15, height: 20))
                        TileView(tile: MahjongTile(id: UUID(), type: .wind(.east), position: BoardPosition(x: 0, y: 0, z: 0)), size: CGSize(width: 15, height: 20))
                    }
                }
            }
        }
        .padding()
    }
}
