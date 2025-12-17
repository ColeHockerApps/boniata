import Foundation
import Combine
import SwiftUI

enum PinataModels {

    enum Rarity: Int, CaseIterable, Codable, Comparable {
        case common = 0
        case uncommon = 1
        case rare = 2
        case epic = 3
        case legendary = 4

        static func < (lhs: Rarity, rhs: Rarity) -> Bool { lhs.rawValue < rhs.rawValue }

        var label: String {
            switch self {
            case .common: return "Common"
            case .uncommon: return "Uncommon"
            case .rare: return "Rare"
            case .epic: return "Epic"
            case .legendary: return "Legendary"
            }
        }
    }

    enum RewardKind: String, Codable, CaseIterable {
        case coins
        case candy
        case boosters
        case hearts
        case keys
        case tickets
    }

    enum BoosterKind: String, Codable, CaseIterable {
        case doubleTap
        case magnet
        case shield
        case frenzy
        case bonusDrop
    }

    enum EffectKind: String, Codable, CaseIterable {
        case tapPowerUp
        case tapSpeedUp
        case critChanceUp
        case critPowerUp
        case bonusMultiplierUp
        case damageReduction
    }

    struct Reward: Identifiable, Codable, Hashable {
        let id: UUID
        let kind: RewardKind
        let amount: Int
        let rarity: Rarity

        init(kind: RewardKind, amount: Int, rarity: Rarity) {
            self.id = UUID()
            self.kind = kind
            self.amount = max(0, amount)
            self.rarity = rarity
        }

        var title: String {
            "\(kind.rawValue.capitalized) x\(amount)"
        }
    }

    struct Booster: Identifiable, Codable, Hashable {
        let id: UUID
        let kind: BoosterKind
        let seconds: Int
        let rarity: Rarity

        init(kind: BoosterKind, seconds: Int, rarity: Rarity) {
            self.id = UUID()
            self.kind = kind
            self.seconds = max(1, seconds)
            self.rarity = rarity
        }

        var title: String {
            "\(kind.rawValue.capitalized) (\(seconds)s)"
        }
    }

    struct Effect: Identifiable, Codable, Hashable {
        let id: UUID
        let kind: EffectKind
        let value: Double
        let seconds: Int
        let rarity: Rarity

        init(kind: EffectKind, value: Double, seconds: Int, rarity: Rarity) {
            self.id = UUID()
            self.kind = kind
            self.value = value
            self.seconds = max(1, seconds)
            self.rarity = rarity
        }
    }

    struct TapEvent: Identifiable, Codable, Hashable {
        let id: UUID
        let at: TimeInterval
        let power: Double
        let isCritical: Bool

        init(at: TimeInterval, power: Double, isCritical: Bool) {
            self.id = UUID()
            self.at = at
            self.power = max(0, power)
            self.isCritical = isCritical
        }
    }

    struct TapSnapshot: Codable, Hashable {
        let taps: Int
        let totalDamage: Double
        let criticals: Int
        let streakBest: Int
        let lastTapAt: TimeInterval

        init(taps: Int, totalDamage: Double, criticals: Int, streakBest: Int, lastTapAt: TimeInterval) {
            self.taps = max(0, taps)
            self.totalDamage = max(0, totalDamage)
            self.criticals = max(0, criticals)
            self.streakBest = max(0, streakBest)
            self.lastTapAt = max(0, lastTapAt)
        }
    }

    struct PinataSkin: Identifiable, Codable, Hashable {
        let id: UUID
        let name: String
        let rarity: Rarity
        let hueShift: Double
        let glow: Double

        init(name: String, rarity: Rarity, hueShift: Double, glow: Double) {
            self.id = UUID()
            self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            self.rarity = rarity
            self.hueShift = hueShift
            self.glow = glow
        }
    }

    struct SessionConfig: Codable, Hashable {
        let baseTapPower: Double
        let baseCritChance: Double
        let baseCritMultiplier: Double
        let tapCooldownMs: Int
        let streakWindowMs: Int
        let maxStreakBonus: Double

        init(
            baseTapPower: Double,
            baseCritChance: Double,
            baseCritMultiplier: Double,
            tapCooldownMs: Int,
            streakWindowMs: Int,
            maxStreakBonus: Double
        ) {
            self.baseTapPower = max(0.01, baseTapPower)
            self.baseCritChance = min(max(0, baseCritChance), 1.0)
            self.baseCritMultiplier = max(1.0, baseCritMultiplier)
            self.tapCooldownMs = max(0, tapCooldownMs)
            self.streakWindowMs = max(100, streakWindowMs)
            self.maxStreakBonus = max(0, maxStreakBonus)
        }

        static func vividDefault() -> SessionConfig {
            SessionConfig(
                baseTapPower: 1.0,
                baseCritChance: 0.08,
                baseCritMultiplier: 2.25,
                tapCooldownMs: 30,
                streakWindowMs: 650,
                maxStreakBonus: 0.65
            )
        }
    }

    struct DropTable: Codable, Hashable {
        let rewards: [RewardChance]
        let boosters: [BoosterChance]

        init(rewards: [RewardChance], boosters: [BoosterChance]) {
            self.rewards = rewards
            self.boosters = boosters
        }
    }

    struct RewardChance: Codable, Hashable {
        let kind: RewardKind
        let minAmount: Int
        let maxAmount: Int
        let rarity: Rarity
        let weight: Int

        init(kind: RewardKind, minAmount: Int, maxAmount: Int, rarity: Rarity, weight: Int) {
            self.kind = kind
            self.minAmount = max(0, minAmount)
            self.maxAmount = max(self.minAmount, maxAmount)
            self.rarity = rarity
            self.weight = max(0, weight)
        }
    }

    struct BoosterChance: Codable, Hashable {
        let kind: BoosterKind
        let minSeconds: Int
        let maxSeconds: Int
        let rarity: Rarity
        let weight: Int

        init(kind: BoosterKind, minSeconds: Int, maxSeconds: Int, rarity: Rarity, weight: Int) {
            self.kind = kind
            self.minSeconds = max(1, minSeconds)
            self.maxSeconds = max(self.minSeconds, maxSeconds)
            self.rarity = rarity
            self.weight = max(0, weight)
        }
    }

    struct SpinBonus: Codable, Hashable {
        let multiplier: Double
        let seconds: Int

        init(multiplier: Double, seconds: Int) {
            self.multiplier = max(1.0, multiplier)
            self.seconds = max(1, seconds)
        }
    }

    struct LootCrate: Identifiable, Codable, Hashable {
        let id: UUID
        let name: String
        let rarity: Rarity
        let guaranteed: RewardKind?
        let table: DropTable

        init(name: String, rarity: Rarity, guaranteed: RewardKind?, table: DropTable) {
            self.id = UUID()
            self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
            self.rarity = rarity
            self.guaranteed = guaranteed
            self.table = table
        }
    }
}
