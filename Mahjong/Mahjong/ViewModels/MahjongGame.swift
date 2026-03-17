import Foundation
import Combine
import SwiftUI

class MahjongGame: ObservableObject {
    @Published var activeTiles: [MahjongTile] = []
    @Published var selectedTile: MahjongTile? = nil
    @Published var hintedTileIDs: Set<UUID> = []
    @Published var matchedCount: Int = 0
    @Published var isGameOver: Bool = false
    @Published var isNoMovesLeft: Bool = false
    
    private var hintTimer: AnyCancellable?
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        isGameOver = false
        isNoMovesLeft = false
        
        // 1. Prepare 56-tile deck (28 pairs)
        var fullDeck: [TileType] = []
        for suit in MahjongSuit.allCases {
            for val in 1...7 {
                for _ in 0..<2 { fullDeck.append(.suit(suit, val)) }
            }
        }
        for wind in MahjongWind.allCases {
            for _ in 0..<2 { fullDeck.append(.wind(wind)) }
        }
        for dragon in MahjongDragon.allCases {
            for _ in 0..<2 { fullDeck.append(.dragon(dragon)) }
        }
        
        let layout = generateMobileLayout()
        
        // 2. Try generating a solvable board
        var attempts = 0
        while attempts < 100 {
            attempts += 1
            var shuffledDeck = fullDeck.shuffled()
            var tiles: [MahjongTile] = []
            for (i, pos) in layout.enumerated() {
                tiles.append(MahjongTile(id: UUID(), type: shuffledDeck[i], position: pos))
            }
            
            if canSolve(tiles) {
                self.activeTiles = tiles
                break
            }
        }
        
        self.selectedTile = nil
        self.hintedTileIDs = []
        self.matchedCount = 0
    }
    
    // Simple solver to verify the board
    private func canSolve(_ tiles: [MahjongTile]) -> Bool {
        var currentTiles = tiles
        while true {
            let freeTiles = currentTiles.filter { t in isPositionFree(t.position, in: currentTiles.map { $0.position }) }
            var foundMatch = false
            
            for i in 0..<freeTiles.count {
                for j in (i + 1)..<freeTiles.count {
                    if freeTiles[i].type.matches(freeTiles[j].type) {
                        let id1 = freeTiles[i].id
                        let id2 = freeTiles[j].id
                        currentTiles.removeAll { $0.id == id1 || $0.id == id2 }
                        foundMatch = true
                        break
                    }
                }
                if foundMatch { break }
            }
            
            if currentTiles.isEmpty { return true }
            if !foundMatch { return false }
        }
    }
    
    private func generateMobileLayout() -> [BoardPosition] {
        var pos: [BoardPosition] = []
        for y in 0..<6 {
            for x in 0..<6 { pos.append(BoardPosition(x: Double(x), y: Double(y), z: 0)) }
        }
        for y in 1..<5 {
            for x in 1..<5 { pos.append(BoardPosition(x: Double(x), y: Double(y), z: 1)) }
        }
        for y in 2..<4 {
            for x in 2..<4 { pos.append(BoardPosition(x: Double(x), y: Double(y), z: 2)) }
        }
        return Array(pos.prefix(56))
    }
    
    private func isPositionFree(_ pos: BoardPosition, in pool: [BoardPosition]) -> Bool {
        let onTop = pool.contains { 
            $0.z > pos.z && abs($0.x - pos.x) < 1.0 && abs($0.y - pos.y) < 1.0
        }
        if onTop { return false }
        let leftBlocked = pool.contains { 
            $0.z == pos.z && $0.x == pos.x - 1.0 && abs($0.y - pos.y) < 1.0
        }
        let rightBlocked = pool.contains { 
            $0.z == pos.z && $0.x == pos.x + 1.0 && abs($0.y - pos.y) < 1.0
        }
        return !leftBlocked || !rightBlocked
    }
    
    func selectTile(_ tile: MahjongTile) {
        guard isFree(tile) else { return }
        hintedTileIDs = []
        
        if let first = selectedTile {
            if first.id == tile.id {
                selectedTile = nil
            } else if first.type.matches(tile.type) {
                withAnimation {
                    activeTiles.removeAll { $0.id == first.id || $0.id == tile.id }
                    matchedCount += 2
                }
                selectedTile = nil
                checkGameState()
            } else {
                selectedTile = tile
            }
        } else {
            selectedTile = tile
        }
    }
    
    private func checkGameState() {
        if activeTiles.isEmpty {
            isGameOver = true
        } else if !hasMoves() {
            isNoMovesLeft = true
        }
    }
    
    private func hasMoves() -> Bool {
        let freeTiles = activeTiles.filter { isFree($0) }
        for i in 0..<freeTiles.count {
            for j in (i + 1)..<freeTiles.count {
                if freeTiles[i].type.matches(freeTiles[j].type) { return true }
            }
        }
        return false
    }
    
    func isFree(_ tile: MahjongTile) -> Bool {
        return isPositionFree(tile.position, in: activeTiles.map { $0.position })
    }

    func findHint() {
        hintedTileIDs = []
        let freeTiles = activeTiles.filter { isFree($0) }
        for i in 0..<freeTiles.count {
            for j in (i + 1)..<freeTiles.count {
                if freeTiles[i].type.matches(freeTiles[j].type) {
                    hintedTileIDs = [freeTiles[i].id, freeTiles[j].id]
                    
                    hintTimer?.cancel()
                    hintTimer = Just(())
                        .delay(for: .seconds(3), scheduler: RunLoop.main)
                        .sink { [weak self] _ in self?.hintedTileIDs = [] }
                    return
                }
            }
        }
    }
}
