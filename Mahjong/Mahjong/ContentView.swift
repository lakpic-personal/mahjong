import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var game = MahjongGame()
    
    // Core Layout Constants for Mobile (Simplified grid)
    let gridWidth: Double = 6.0
    let gridHeight: Double = 6.0
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width - 60
            let availableHeight = geometry.size.height - 180
            
            let scaleX = availableWidth / CGFloat(gridWidth)
            let scaleY = availableHeight / CGFloat(gridHeight)
            let scale = min(scaleX, scaleY, 60)
            
            let tileWidth = scale
            let tileHeight = scale * 1.35
            
            VStack {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Mahjong Solitaire")
                            .font(.system(.title, design: .rounded, weight: .bold))
                        Text("Matched: \(game.matchedCount) / 56")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Button(action: { game.findHint() }) {
                            VStack {
                                Image(systemName: "lightbulb.fill")
                                    .font(.title)
                                    .foregroundColor(.yellow)
                                Text("Hint")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: { game.startNewGame() }) {
                            VStack {
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.green)
                                Text("New")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Game Board
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(red: 0.1, green: 0.35, blue: 0.15))
                        .shadow(radius: 15)
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
                                x: CGFloat(tile.position.x - 2.5) * (tileWidth + 4) + (geometry.size.width / 2),
                                y: CGFloat(tile.position.y - 2.5) * (tileHeight * 0.8) + (availableHeight / 2)
                            )
                            .offset(
                                x: CGFloat(tile.position.z) * -4,
                                y: CGFloat(tile.position.z) * -4
                            )
                            .onTapGesture {
                                withAnimation {
                                    game.selectTile(tile)
                                }
                            }
                        }
                    }
                    
                    // Win / Stuck States
                    if game.isGameOver {
                        StatusOverlay(title: "YOU WIN!", color: .yellow) { game.startNewGame() }
                    } else if game.isNoMovesLeft {
                        StatusOverlay(title: "STUCK!", subtitle: "No more moves left", color: .red) { game.startNewGame() }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer().frame(height: 30)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct StatusOverlay: View {
    let title: String
    var subtitle: String? = nil
    let color: Color
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(color)
                .shadow(radius: 10)
            
            if let sub = subtitle {
                Text(sub)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Button("New Game") { action() }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)
        }
        .padding(40)
        .background(Color.black.opacity(0.85))
        .cornerRadius(30)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
