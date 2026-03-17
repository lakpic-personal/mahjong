import SwiftUI

struct TileView: View {
    let tile: MahjongTile
    var isSelected: Bool = false
    var isFree: Bool = true
    var isHinted: Bool = false
    var size: CGSize = CGSize(width: 32, height: 44)
    
    @State private var pulseOpacity: Double = 0.2
    
    var body: some View {
        ZStack {
            // Side Thickness (Depth)
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 0.85, green: 0.85, blue: 0.75))
                .offset(x: 3, y: 3)
            
            // Front Face
            RoundedRectangle(cornerRadius: 6)
                .fill(isFree ? Color.white : Color(white: 0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            isSelected ? Color.orange : Color.gray.opacity(0.4), 
                            lineWidth: isSelected ? 3 : 1
                        )
                )
                .shadow(radius: isSelected ? 10 : 2)
            
            // Symbol
            Text(tile.type.symbol)
                .font(.system(size: size.width * 0.6, weight: .bold, design: .rounded))
                .foregroundColor(symbolColor)
                .minimumScaleFactor(0.4)
                .padding(2)
            
            // Hint Overlay (Two tiles should pulsate)
            if isHinted {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.yellow.opacity(pulseOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.yellow, lineWidth: 3)
                    )
                    .onAppear {
                        withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            pulseOpacity = 0.6
                        }
                    }
            }
        }
        .frame(width: size.width, height: size.height)
        .scaleEffect(isSelected ? 1.15 : (isHinted ? 1.05 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
    
    private var symbolColor: Color {
        switch tile.type {
        case .suit(let suit, _):
            switch suit {
            case .dots: return .blue
            case .bamboo: return .green
            case .characters: return .red
            }
        case .wind: return .black
        case .dragon(let dragon):
            switch dragon {
            case .red: return .red
            case .green: return .green
            case .white: return .blue
            }
        case .flower, .season: return .purple
        }
    }
}
