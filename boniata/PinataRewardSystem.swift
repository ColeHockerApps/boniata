import Foundation
import Combine
import SwiftUI

@MainActor
final class PinataRewardSystem: ObservableObject {

    @Published private(set) var lastRewards: [PinataModels.Reward] = []
    @Published private(set) var lastBoosters: [PinataModels.Booster] = []
    @Published private(set) var lastSpin: PinataModels.SpinBonus? = nil

    @Published private(set) var coinsTotal: Int = 0
    @Published private(set) var candyTotal: Int = 0
    @Published private(set) var keysTotal: Int = 0

    private var table: PinataModels.DropTable
    private var bag: [Int] = []
    private var rng = SystemRandomNumberGenerator()

    init() {
        table = PinataRewardSystem.crimsonTable()
        refillBag()
    }

    func setTable(_ newTable: PinataModels.DropTable) {
        table = newTable
        refillBag()
    }

    func resetAll() {
        lastRewards.removeAll()
        lastBoosters.removeAll()
        lastSpin = nil
        coinsTotal = 0
        candyTotal = 0
        keysTotal = 0
        refillBag()
    }

    func rollBundle(count: Int) -> [PinataModels.Reward] {
        let c = min(max(1, count), 8)
        var list: [PinataModels.Reward] = []
        list.reserveCapacity(c)

        for _ in 0..<c {
            let r = rollSingleReward()
            list.append(r)
            applyRewardToTotals(r)
        }

        lastRewards = list
        return list
    }

    func rollBoosterBundle(count: Int) -> [PinataModels.Booster] {
        let c = min(max(1, count), 4)
        var list: [PinataModels.Booster] = []
        list.reserveCapacity(c)

        for _ in 0..<c {
            let b = rollSingleBooster()
            list.append(b)
        }

        lastBoosters = list
        return list
    }

    func rollSpinBonus() -> PinataModels.SpinBonus {
        let roll = Int.random(in: 1...100)

        if roll <= 55 {
            lastSpin = PinataModels.SpinBonus(multiplier: 1.25, seconds: 10)
        } else if roll <= 80 {
            lastSpin = PinataModels.SpinBonus(multiplier: 1.5, seconds: 9)
        } else if roll <= 93 {
            lastSpin = PinataModels.SpinBonus(multiplier: 1.75, seconds: 8)
        } else {
            lastSpin = PinataModels.SpinBonus(multiplier: 2.0, seconds: 7)
        }

        return lastSpin!
    }

    func rollCrate(name: String, rarity: PinataModels.Rarity) -> PinataModels.LootCrate {
        let guaranteed: PinataModels.RewardKind?
        if rarity >= .epic {
            guaranteed = .keys
        } else if rarity >= .rare {
            guaranteed = .candy
        } else {
            guaranteed = nil
        }

        let crate = PinataModels.LootCrate(
            name: name,
            rarity: rarity,
            guaranteed: guaranteed,
            table: table
        )

        return crate
    }

    // MARK: - Internals

    private func refillBag() {
        bag.removeAll(keepingCapacity: true)

        for (index, item) in table.rewards.enumerated() {
            let w = max(0, item.weight)
            if w == 0 { continue }
            for _ in 0..<w {
                bag.append(index)
            }
        }

        if bag.isEmpty {
            bag = Array(repeating: 0, count: 10)
        }

        bag.shuffle()
    }

    private func pullIndex() -> Int {
        if bag.isEmpty {
            refillBag()
        }
        return bag.removeLast()
    }

    private func rollSingleReward() -> PinataModels.Reward {
        let idx = pullIndex()
        let info = table.rewards[min(max(0, idx), table.rewards.count - 1)]

        let amount: Int
        if info.minAmount == info.maxAmount {
            amount = info.minAmount
        } else {
            amount = Int.random(in: info.minAmount...info.maxAmount)
        }

        return PinataModels.Reward(kind: info.kind, amount: amount, rarity: info.rarity)
    }

    private func rollSingleBooster() -> PinataModels.Booster {
        let list = table.boosters
        if list.isEmpty {
            return PinataModels.Booster(kind: .bonusDrop, seconds: 10, rarity: .uncommon)
        }

        var weighted: [Int] = []
        weighted.reserveCapacity(80)

        for (i, b) in list.enumerated() {
            let w = max(0, b.weight)
            if w == 0 { continue }
            for _ in 0..<w {
                weighted.append(i)
            }
        }

        if weighted.isEmpty {
            weighted = Array(0..<list.count)
        }

        let pick = weighted[Int.random(in: 0..<weighted.count)]
        let info = list[min(max(0, pick), list.count - 1)]

        let seconds: Int
        if info.minSeconds == info.maxSeconds {
            seconds = info.minSeconds
        } else {
            seconds = Int.random(in: info.minSeconds...info.maxSeconds)
        }

        return PinataModels.Booster(kind: info.kind, seconds: seconds, rarity: info.rarity)
    }

    private func applyRewardToTotals(_ reward: PinataModels.Reward) {
        switch reward.kind {
        case .coins:
            coinsTotal += reward.amount
        case .candy:
            candyTotal += reward.amount
        case .keys:
            keysTotal += reward.amount
        case .boosters:
            break
        case .hearts:
            break
        case .tickets:
            coinsTotal += reward.amount
        }
    }

    // MARK: - Tables

    static func crimsonTable() -> PinataModels.DropTable {
        let rewards: [PinataModels.RewardChance] = [
            .init(kind: .coins, minAmount: 6, maxAmount: 22, rarity: .common, weight: 52),
            .init(kind: .candy, minAmount: 2, maxAmount: 10, rarity: .uncommon, weight: 22),
            .init(kind: .keys, minAmount: 1, maxAmount: 3, rarity: .rare, weight: 14),
            .init(kind: .hearts, minAmount: 6, maxAmount: 16, rarity: .epic, weight: 8),
            .init(kind: .boosters, minAmount: 1, maxAmount: 1, rarity: .legendary, weight: 4)
        ]

        let boosters: [PinataModels.BoosterChance] = [
            .init(kind: .doubleTap, minSeconds: 8, maxSeconds: 18, rarity: .uncommon, weight: 38),
            .init(kind: .bonusDrop, minSeconds: 8, maxSeconds: 16, rarity: .rare, weight: 26),
            .init(kind: .magnet, minSeconds: 10, maxSeconds: 18, rarity: .rare, weight: 18),
            .init(kind: .shield, minSeconds: 10, maxSeconds: 16, rarity: .epic, weight: 12),
            .init(kind: .frenzy, minSeconds: 6, maxSeconds: 12, rarity: .legendary, weight: 6)
        ]

        return PinataModels.DropTable(rewards: rewards, boosters: boosters)
    }
}
