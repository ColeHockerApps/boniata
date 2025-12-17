import SwiftUI
import Combine

enum BoniataAssets {

    enum Names {
        static let appDisplayName = "Boniata"
    }

    enum Motion {
        static let loadingDuration: TimeInterval = 3.0
        static let fadeOutDuration: TimeInterval = 0.30
        static let readyFadeInDuration: TimeInterval = 0.30
    }

    enum Visual {
        static let glowRadius: CGFloat = 28
        static let softShadowRadius: CGFloat = 16
        static let cardStrokeWidth: CGFloat = 1.2
    }

    enum Tokens {
        static let settingsSoundsKey = "boniata.settings.sounds"
        static let settingsHapticsKey = "boniata.settings.haptics"
        static let entryKey = "boniata.entry.point"
        static let privacyKey = "boniata.privacy.point"
        static let trailKey = "boniata.trail.mark"
        static let marksKey = "boniata.trail.marks"
    }
}
