import Foundation
import Combine
import SwiftUI

struct PinataLevelConfig: Codable, Hashable {
    let levelId: Int
    let title: String

    let pinataHealth: Double
    let baseTapPower: Double
    let critChance: Double
    let critMultiplier: Double

    let streakWindowMs: Int
    let maxStreakBonus: Double

    let bonusDrops: Int
    let boosterSlots: Int

    let targetCoins: Int
    let targetCandy: Int
    let targetKeys: Int

    init(
        levelId: Int,
        title: String,
        pinataHealth: Double,
        baseTapPower: Double,
        critChance: Double,
        critMultiplier: Double,
        streakWindowMs: Int,
        maxStreakBonus: Double,
        bonusDrops: Int,
        boosterSlots: Int,
        targetCoins: Int,
        targetCandy: Int,
        targetKeys: Int
    ) {
        self.levelId = max(1, levelId)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.pinataHealth = max(5.0, pinataHealth)
        self.baseTapPower = max(0.05, baseTapPower)
        self.critChance = min(max(0.0, critChance), 1.0)
        self.critMultiplier = max(1.0, critMultiplier)
        self.streakWindowMs = max(150, streakWindowMs)
        self.maxStreakBonus = max(0.0, maxStreakBonus)
        self.bonusDrops = max(0, bonusDrops)
        self.boosterSlots = max(0, boosterSlots)
        self.targetCoins = max(0, targetCoins)
        self.targetCandy = max(0, targetCandy)
        self.targetKeys = max(0, targetKeys)
    }

    static func warmUp(_ id: Int) -> PinataLevelConfig {
        PinataLevelConfig(
            levelId: id,
            title: "Warm Up",
            pinataHealth: 70,
            baseTapPower: 1.0,
            critChance: 0.08,
            critMultiplier: 2.2,
            streakWindowMs: 720,
            maxStreakBonus: 0.55,
            bonusDrops: 1,
            boosterSlots: 1,
            targetCoins: 80,
            targetCandy: 18,
            targetKeys: 1
        )
    }

    static func brisk(_ id: Int) -> PinataLevelConfig {
        PinataLevelConfig(
            levelId: id,
            title: "Brisk",
            pinataHealth: 110,
            baseTapPower: 0.95,
            critChance: 0.09,
            critMultiplier: 2.25,
            streakWindowMs: 660,
            maxStreakBonus: 0.60,
            bonusDrops: 2,
            boosterSlots: 2,
            targetCoins: 140,
            targetCandy: 28,
            targetKeys: 2
        )
    }

    static func fierce(_ id: Int) -> PinataLevelConfig {
        PinataLevelConfig(
            levelId: id,
            title: "Fierce",
            pinataHealth: 165,
            baseTapPower: 0.88,
            critChance: 0.10,
            critMultiplier: 2.35,
            streakWindowMs: 610,
            maxStreakBonus: 0.68,
            bonusDrops: 3,
            boosterSlots: 2,
            targetCoins: 220,
            targetCandy: 42,
            targetKeys: 3
        )
    }

    static func nightRun(_ id: Int) -> PinataLevelConfig {
        PinataLevelConfig(
            levelId: id,
            title: "Night Run",
            pinataHealth: 215,
            baseTapPower: 0.82,
            critChance: 0.11,
            critMultiplier: 2.45,
            streakWindowMs: 560,
            maxStreakBonus: 0.74,
            bonusDrops: 4,
            boosterSlots: 3,
            targetCoins: 290,
            targetCandy: 60,
            targetKeys: 4
        )
    }

    static func crimson(_ id: Int) -> PinataLevelConfig {
        PinataLevelConfig(
            levelId: id,
            title: "Crimson",
            pinataHealth: 275,
            baseTapPower: 0.78,
            critChance: 0.12,
            critMultiplier: 2.6,
            streakWindowMs: 520,
            maxStreakBonus: 0.80,
            bonusDrops: 5,
            boosterSlots: 3,
            targetCoins: 380,
            targetCandy: 78,
            targetKeys: 5
        )
    }

    static func sampleSet() -> [PinataLevelConfig] {
        [
            warmUp(1),
            brisk(2),
            fierce(3),
            nightRun(4),
            crimson(5)
        ]
    }
}

final class PinataLevelDeck: ObservableObject {
    @Published private(set) var levels: [PinataLevelConfig] = []
    @Published private(set) var currentIndex: Int = 0

    init() {
        levels = PinataLevelConfig.sampleSet()
        currentIndex = 0
    }

    func current() -> PinataLevelConfig {
        if levels.isEmpty {
            return PinataLevelConfig.warmUp(1)
        }
        let idx = min(max(0, currentIndex), levels.count - 1)
        return levels[idx]
    }

    func setIndex(_ value: Int) {
        if levels.isEmpty {
            currentIndex = 0
            return
        }
        currentIndex = min(max(0, value), levels.count - 1)
    }

    func advance() {
        if levels.isEmpty {
            currentIndex = 0
            return
        }
        currentIndex = min(currentIndex + 1, levels.count - 1)
    }

    func rewind() {
        if levels.isEmpty {
            currentIndex = 0
            return
        }
        currentIndex = max(currentIndex - 1, 0)
    }

    func rebuild(count: Int) {
        let c = max(1, count)
        var list: [PinataLevelConfig] = []
        list.reserveCapacity(c)

        for i in 1...c {
            let mode = i % 5
            if mode == 0 {
                list.append(PinataLevelConfig.crimson(i))
            } else if mode == 1 {
                list.append(PinataLevelConfig.warmUp(i))
            } else if mode == 2 {
                list.append(PinataLevelConfig.brisk(i))
            } else if mode == 3 {
                list.append(PinataLevelConfig.fierce(i))
            } else {
                list.append(PinataLevelConfig.nightRun(i))
            }
        }

        levels = list
        currentIndex = 0
    }
}
