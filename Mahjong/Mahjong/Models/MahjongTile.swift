import Foundation

enum MahjongSuit: String, CaseIterable, Codable {
    case dots, bamboo, characters
}

enum MahjongWind: String, CaseIterable, Codable {
    case east, south, west, north
}

enum MahjongDragon: String, CaseIterable, Codable {
    case red, green, white
}

enum TileType: Codable, Equatable, Hashable {
    case suit(MahjongSuit, Int)
    case wind(MahjongWind)
    case dragon(MahjongDragon)
    case flower(Int)
    case season(Int)

    var symbol: String {
        switch self {
        case .suit(let suit, let val):
            switch suit {
            case .dots: return "●\(val)"
            case .bamboo: return "🎋\(val)"
            case .characters: return "🀇\(val)"
            }
        case .wind(let wind):
            switch wind {
            case .east: return "東"
            case .south: return "南"
            case .west: return "西"
            case .north: return "北"
            }
        case .dragon(let dragon):
            switch dragon {
            case .red: return "中"
            case .green: return "發"
            case .white: return "□"
            }
        case .flower(let val): return "🌸\(val)"
        case .season(let val): return "🍂\(val)"
        }
    }
    
    func matches(_ other: TileType) -> Bool {
        switch (self, other) {
        case (.flower, .flower): return true
        case (.season, .season): return true
        default: return self == other
        }
    }
}

struct BoardPosition: Equatable, Hashable, Codable {
    let x: Double // Use double for half-tile offsets
    let y: Double
    let z: Int    // Layer (0 is bottom)
}

struct MahjongTile: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let type: TileType
    var position: BoardPosition
    
    static func == (lhs: MahjongTile, rhs: MahjongTile) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
