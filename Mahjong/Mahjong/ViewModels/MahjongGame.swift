import Foundation
import Combine
import SwiftUI

class MahjongGame: ObservableObject {
    @Published var activeTiles: [MahjongTile] = []
    @Published var selectedTile: MahjongTile? = nil
    @Published var hintedTileIDs: Set<UUID> = []
    @Published var matchedCount: Int = 0
    
    private var hintTimer: AnyCancellable?
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        var deck: [TileType] = []
        for suit in MahjongSuit.allCases {
            for val in 1...9 {
                for _ in 0..<4 { deck.append(.suit(suit, val)) }
            }
        }
        for wind in MahjongWind.allCases {
            for _ in 0..<4 { deck.append(.wind(wind)) }
        }
        for dragon in MahjongDragon.allCases {
            for _ in 0..<4 { deck.append(.dragon(dragon)) }
        }
        for i in 1...4 {
            deck.append(.flower(i))
            deck.append(.season(i))
        }
        deck.shuffle()
        
        let layout = generateTurtleLayout()
        var tiles: [MahjongTile] = []
        for (i, pos) in layout.enumerated() {
            if i < deck.count {
                tiles.append(MahjongTile(id: UUID(), type: deck[i], position: pos))
            }
        }
        self.activeTiles = tiles
        self.selectedTile = nil
        self.hintedTileIDs = []
        self.matchedCount = 0
    }
    
    func findHint() {
        hintedTileIDs = []
        let freeTiles = activeTiles.filter { isFree($0) }
        
        for i in 0..<freeTiles.count {
            for j in (i + 1)..<freeTiles.count {
                let t1 = freeTiles[i]
                let t2 = freeTiles[j]
                
                if t1.type.matches(t2.type) {
                    hintedTileIDs = [t1.id, t2.id]
                    
                    // Clear hint after 3 seconds
                    hintTimer?.cancel()
                    hintTimer = Just(())
                        .delay(for: .seconds(3), scheduler: RunLoop.main)
                        .sink { [weak self] _ in self?.hintedTileIDs = [] }
                    return
                }
            }
        }
    }
    
    private func generateTurtleLayout() -> [BoardPosition] {
        var positions: [BoardPosition] = []
        for y in 0..<8 {
            for x in 0..<12 {
                if (y == 0 || y == 7) && (x < 3 || x > 8) { continue }
                positions.append(BoardPosition(x: Double(x), y: Double(y), z: 0))
            }
        }
        for y in 1..<7 {
            for x in 2..<10 {
                positions.append(BoardPosition(x: Double(x), y: Double(y), z: 1))
            }
        }
        for y in 2..<6 {
            for x in 4..<8 {
                positions.append(BoardPosition(x: Double(x), y: Double(y), z: 2))
            }
        }
        positions.append(BoardPosition(x: 5.5, y: 3.5, z: 3))
        positions.append(BoardPosition(x: 6.5, y: 3.5, z: 3))
        return positions
    }
    
    func selectTile(_ tile: MahjongTile) {
        guard isFree(tile) else { return }
        hintedTileIDs = [] // Clear hints on selection
        
        if let first = selectedTile {
            if first.id == tile.id {
                selectedTile = nil
            } else if first.type.matches(tile.type) {
                activeTiles.removeAll { $0.id == first.id || $0.id == tile.id }
                matchedCount += 2
                selectedTile = nil
            } else {
                selectedTile = tile
            }
        } else {
            selectedTile = tile
        }
    }
    
    func isFree(_ tile: MahjongTile) -> Bool {
        let onTop = activeTiles.filter { 
            $0.position.z > tile.position.z &&
            abs($0.position.x - tile.position.x) < 1.0 &&
            abs($0.position.y - tile.position.y) < 1.0
        }
        if !onTop.isEmpty { return false }
        let leftBlocked = activeTiles.contains { 
            $0.position.z == tile.position.z && $0.position.x == tile.position.x - 1.0 && abs($0.position.y - tile.position.y) < 1.0
        }
        let rightBlocked = activeTiles.contains { 
            $0.position.z == tile.position.z && $0.position.x == tile.position.x + 1.0 && abs($0.position.y - tile.position.y) < 1.0
        }
        return !leftBlocked || !rightBlocked
    }
}

