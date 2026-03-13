import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var game = MahjongGame()
    
    // Core Layout Constants
    let gridWidth: Double = 14.0
    let gridHeight: Double = 9.0
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 40
            let availableHeight = geometry.size.height - 150
            
            let scaleX = availableWidth / CGFloat(gridWidth)
            let scaleY = availableHeight / CGFloat(gridHeight)
            let scale = min(scaleX, scaleY, 45)
            
            let tileWidth = scale
            let tileHeight = scale * 1.35
            
            VStack {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Mahjong Solitaire")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        Text("Matched: \(game.matchedCount)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    HStack(spacing: 20) {
                        // Hint Button
                        Button(action: { game.findHint() }) {
                            VStack {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title)
                                    .foregroundColor(.yellow)
                                Text("Hint")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // New Game Button
                        Button(action: { game.startNewGame() }) {
                            VStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                                Text("New")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Game Board
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(red: 0.1, green: 0.4, blue: 0.2))
                        .shadow(radius: 10)
                        .padding(5)
                    
                    ZStack {
                        ForEach(game.activeTiles) { tile in
                            TileView(
                                tile: tile, 
                                isSelected: game.selectedTile?.id == tile.id,
                                isFree: game.isFree(tile),
                                isHinted: game.hintedTileIDs.contains(tile.id),
                                size: CGSize(width: tileWidth, height: tileHeight)
                            )
                            .position(
                                x: CGFloat(tile.position.x - 5.5) * (tileWidth + 2) + (geometry.size.width / 2),
                                y: CGFloat(tile.position.y - 3.5) * (tileHeight * 0.8) + (availableHeight / 2)
                            )
                            .offset(
                                x: CGFloat(tile.position.z) * -3,
                                y: CGFloat(tile.position.z) * -3
                            )
                            .onTapGesture {
                                game.selectTile(tile)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer().frame(height: 20)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

