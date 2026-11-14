import SwiftUI

enum AppTheme {
    static let ink = Color(hex: 0x0E1116)
    static let panel = Color(hex: 0x171C23)
    static let line = Color(hex: 0x2A313B)
    static let paper = Color(hex: 0xECE6D8)
    static let paperInk = Color(hex: 0x14110D)
    static let muted = Color(hex: 0x8D949E)
    static let red = Color(hex: 0xE2402B)

    static let players: [(name: String, color: Color)] = [
        ("Coral", Color(hex: 0xFF7A66)),
        ("Sky", Color(hex: 0x5DB7FF)),
        ("Lime", Color(hex: 0xB5E04A)),
        ("Violet", Color(hex: 0xC58CFF)),
        ("Amber", Color(hex: 0xFFB938)),
        ("Teal", Color(hex: 0x3CC9C4)),
        ("Pink", Color(hex: 0xFF8CCF)),
        ("Sand", Color(hex: 0xE6D3A3)),
        ("Mint", Color(hex: 0x4FD18B)),
        ("Indigo", Color(hex: 0x8C8CFF)),
        ("Orange", Color(hex: 0xFF9A4A)),
        ("White", Color(hex: 0xF2F2F2))
    ]

    static func player(at index: Int) -> (name: String, color: Color) {
        players[index % players.count]
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

struct Eyebrow: View {
    let text: String
    var color: Color = AppTheme.muted

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.bold))
            .tracking(1.4)
            .foregroundStyle(color)
    }
}

struct DisplayTitle: ViewModifier {
    let size: CGFloat
    let color: Color
    @ScaledMetric(relativeTo: .largeTitle) private var scaledSize: CGFloat = 1

    init(size: CGFloat, color: Color) {
        self.size = size
        self.color = color
        _scaledSize = ScaledMetric(wrappedValue: size, relativeTo: .largeTitle)
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: scaledSize, weight: .black, design: .rounded).width(.condensed))
            .textCase(.uppercase)
            .tracking(-0.7)
            .foregroundStyle(color)
    }
}

extension View {
    func displayTitle(size: CGFloat, color: Color = AppTheme.paper) -> some View {
        modifier(DisplayTitle(size: size, color: color))
    }
}

struct FilledButtonStyle: ButtonStyle {
    var fill: Color
    var foreground: Color
    var height: CGFloat = 58
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(foreground.opacity(isEnabled ? 1 : 0.62))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(fill.opacity(isEnabled ? (configuration.isPressed ? 0.78 : 1) : 0.32))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .scaleEffect(configuration.isPressed && isEnabled ? 0.985 : 1)
    }
}
