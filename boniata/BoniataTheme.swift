import SwiftUI
import Combine

enum BoniataTheme {

    enum Colors {
        static let backgroundTop = Color(red: 0.10, green: 0.02, blue: 0.05)
        static let backgroundBottom = Color(red: 0.02, green: 0.02, blue: 0.04)

        static let surface = Color.black.opacity(0.72)
        static let surfaceStrong = Color.black.opacity(0.84)

        static let redPrimary = Color(red: 0.88, green: 0.12, blue: 0.24)
        static let redGlow = Color(red: 1.00, green: 0.18, blue: 0.28).opacity(0.85)

        static let ember = Color(red: 0.98, green: 0.42, blue: 0.24)
        static let emberSoft = Color(red: 1.00, green: 0.54, blue: 0.32).opacity(0.75)

        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.78)
        static let textMuted = Color.white.opacity(0.58)

        static let borderSoft = Color.white.opacity(0.12)
        static let shadow = Color.black.opacity(0.55)
        static let glow = Color(red: 1.00, green: 0.15, blue: 0.25).opacity(0.35)
    }

    enum Fonts {
        static func title(_ size: CGFloat) -> Font {
            .system(size: size, weight: .heavy, design: .rounded)
        }

        static func subtitle(_ size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .rounded)
        }

        static func body(_ size: CGFloat) -> Font {
            .system(size: size, weight: .medium, design: .rounded)
        }

        static func mono(_ size: CGFloat) -> Font {
            .system(size: size, weight: .semibold, design: .monospaced)
        }
    }

    enum Layout {
        static let corner: CGFloat = 20
        static let cornerSmall: CGFloat = 14
        static let pad: CGFloat = 18
    }

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Colors.backgroundTop, Colors.backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
