import Foundation
import Combine
import SwiftUI

@MainActor
final class PinataBoardState: ObservableObject {

    @Published private(set) var isActive: Bool = false
    @Published private(set) var tapsTotal: Int = 0
    @Published private(set) var streakCount: Int = 0
    @Published private(set) var streakBest: Int = 0

    @Published private(set) var pinataHealth: Double = 100.0
    @Published private(set) var pinataMaxHealth: Double = 100.0

    @Published private(set) var critsTotal: Int = 0
    @Published private(set) var damageTotal: Double = 0.0

    @Published private(set) var coins: Int = 0
    @Published private(set) var candy: Int = 0
    @Published private(set) var keys: Int = 0

    @Published private(set) var activeBoosters: [PinataModels.Booster] = []
    @Published private(set) var lastReward: PinataModels.Reward? = nil
    @Published private(set) var lastTap: PinataModels.TapEvent? = nil

    @Published private(set) var lastTapAt: TimeInterval = 0
    @Published private(set) var streakWindowMs: Int = 650

    @Published private(set) var statusLine: String = "Idle"

    private var config: PinataModels.SessionConfig = .vividDefault()
    private var bag = Set<AnyCancellable>()

    init() {
        applyDefaults()
        seedPreviewBoosters()
        refreshStatusLine()
    }

    func startSession() {
        isActive = true
        pinataMaxHealth = max(10.0, pinataMaxHealth)
        pinataHealth = min(pinataHealth, pinataMaxHealth)
        streakCount = 0
        lastTapAt = 0
        refreshStatusLine()
    }

    func stopSession() {
        isActive = false
        streakCount = 0
        lastTapAt = 0
        refreshStatusLine()
    }

    func resetAllProgress() {
        isActive = false
        tapsTotal = 0
        streakCount = 0
        streakBest = 0
        pinataMaxHealth = 100.0
        pinataHealth = 100.0
        critsTotal = 0
        damageTotal = 0.0
        coins = 0
        candy = 0
        keys = 0
        activeBoosters.removeAll()
        lastReward = nil
        lastTap = nil
        lastTapAt = 0
        streakWindowMs = config.streakWindowMs
        refreshStatusLine()
    }

    func applyDefaultConfig() {
        config = .vividDefault()
        streakWindowMs = config.streakWindowMs
        pinataMaxHealth = 100.0
        pinataHealth = min(pinataHealth, pinataMaxHealth)
        refreshStatusLine()
    }

    func simulateTap() {
        guard isActive else {
            statusLine = "Tap ignored (inactive)"
            return
        }

        let now = Date().timeIntervalSince1970
        let withinWindow = (now - lastTapAt) * 1000.0 <= Double(streakWindowMs)
        lastTapAt = now

        if withinWindow {
            streakCount += 1
        } else {
            streakCount = 1
        }

        if streakCount > streakBest {
            streakBest = streakCount
        }

        tapsTotal += 1

        let isCrit = rollCritical()
        if isCrit {
            critsTotal += 1
        }

        let power = computeTapPower(isCritical: isCrit)
        applyDamage(power)

        lastTap = PinataModels.TapEvent(at: now, power: power, isCritical: isCrit)
        refreshStatusLine()
    }

    func simulateDrop() {
        guard isActive else {
            statusLine = "Drop skipped (inactive)"
            return
        }

        let reward = rollReward()
        lastReward = reward

        switch reward.kind {
        case .coins:
            coins += reward.amount
        case .candy:
            candy += reward.amount
        case .keys:
            keys += reward.amount
        case .boosters:
            let b = rollBooster()
            activeBoosters.append(b)
        case .hearts:
            healPinata(Double(reward.amount))
        case .tickets:
            coins += reward.amount
        }

        refreshStatusLine()
    }

    func refillPinata() {
        pinataHealth = pinataMaxHealth
        streakCount = 0
        lastTapAt = 0
        refreshStatusLine()
    }

    func drainPinata() {
        pinataHealth = 0
        streakCount = 0
        refreshStatusLine()
    }

    func snapshot() -> PinataModels.TapSnapshot {
        let snap = PinataModels.TapSnapshot(
            taps: tapsTotal,
            totalDamage: damageTotal,
            criticals: critsTotal,
            streakBest: streakBest,
            lastTapAt: lastTapAt
        )
        return snap
    }

    // MARK: - Internals

    private func applyDefaults() {
        config = .vividDefault()
        streakWindowMs = config.streakWindowMs
        pinataMaxHealth = 100.0
        pinataHealth = 100.0
        statusLine = "Ready"
    }

    private func seedPreviewBoosters() {
        activeBoosters = [
            PinataModels.Booster(kind: .doubleTap, seconds: 12, rarity: .uncommon),
            PinataModels.Booster(kind: .frenzy, seconds: 8, rarity: .rare)
        ]
    }

    private func rollCritical() -> Bool {
        let p = config.baseCritChance + currentCritBonus()
        let r = Double.random(in: 0...1)
        let ok = r < min(max(0.0, p), 1.0)
        return ok
    }

    private func computeTapPower(isCritical: Bool) -> Double {
        let base = config.baseTapPower
        let streakBonus = min(Double(streakCount) * 0.02, config.maxStreakBonus)
        let boosterBonus = currentPowerBonus()
        let raw = base * (1.0 + streakBonus + boosterBonus)

        if isCritical {
            return raw * config.baseCritMultiplier
        } else {
            return raw
        }
    }

    private func applyDamage(_ value: Double) {
        let dmg = max(0.0, value)
        damageTotal += dmg
        pinataHealth = max(0.0, pinataHealth - dmg)

        if pinataHealth <= 0 {
            statusLine = "Pinata popped!"
        }
    }

    private func healPinata(_ value: Double) {
        let heal = max(0.0, value)
        pinataHealth = min(pinataMaxHealth, pinataHealth + heal)
    }

    private func currentPowerBonus() -> Double {
        var bonus = 0.0

        for b in activeBoosters {
            switch b.kind {
            case .doubleTap:
                bonus += 0.12
            case .magnet:
                bonus += 0.04
            case .shield:
                bonus += 0.02
            case .frenzy:
                bonus += 0.18
            case .bonusDrop:
                bonus += 0.06
            }
        }

        return min(0.65, bonus)
    }

    private func currentCritBonus() -> Double {
        var bonus = 0.0

        for b in activeBoosters {
            switch b.kind {
            case .frenzy:
                bonus += 0.06
            case .doubleTap:
                bonus += 0.02
            default:
                bonus += 0.0
            }
        }

        return min(0.18, bonus)
    }

    private func rollReward() -> PinataModels.Reward {
        let roll = Int.random(in: 1...100)

        if roll <= 55 {
            return PinataModels.Reward(kind: .coins, amount: Int.random(in: 5...18), rarity: .common)
        } else if roll <= 75 {
            return PinataModels.Reward(kind: .candy, amount: Int.random(in: 2...8), rarity: .uncommon)
        } else if roll <= 90 {
            return PinataModels.Reward(kind: .keys, amount: Int.random(in: 1...3), rarity: .rare)
        } else if roll <= 97 {
            return PinataModels.Reward(kind: .boosters, amount: 1, rarity: .epic)
        } else {
            return PinataModels.Reward(kind: .hearts, amount: Int.random(in: 6...18), rarity: .legendary)
        }
    }

    private func rollBooster() -> PinataModels.Booster {
        let roll = Int.random(in: 1...100)

        if roll <= 45 {
            return PinataModels.Booster(kind: .doubleTap, seconds: Int.random(in: 8...16), rarity: .uncommon)
        } else if roll <= 70 {
            return PinataModels.Booster(kind: .bonusDrop, seconds: Int.random(in: 8...14), rarity: .rare)
        } else if roll <= 88 {
            return PinataModels.Booster(kind: .magnet, seconds: Int.random(in: 10...18), rarity: .rare)
        } else if roll <= 97 {
            return PinataModels.Booster(kind: .shield, seconds: Int.random(in: 10...16), rarity: .epic)
        } else {
            return PinataModels.Booster(kind: .frenzy, seconds: Int.random(in: 6...12), rarity: .legendary)
        }
    }

    private func refreshStatusLine() {
        if isActive == false {
            statusLine = "Idle"
            return
        }

        if pinataHealth <= 0 {
            statusLine = "Pinata popped!"
            return
        }

        let hp = Int(pinataHealth.rounded())
        let st = streakCount
        let ct = critsTotal
        let cn = coins
        statusLine = "HP \(hp) • Streak \(st) • Crit \(ct) • Coins \(cn)"
    }
}
