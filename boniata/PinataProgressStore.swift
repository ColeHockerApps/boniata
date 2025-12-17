import Foundation
import Combine
import SwiftUI

@MainActor
final class PinataProgressStore: ObservableObject {

    struct Snapshot: Codable, Hashable {
        let coins: Int
        let candy: Int
        let keys: Int
        let bestStreak: Int
        let totalTaps: Int
        let totalDamage: Double
        let lastLevelId: Int
        let lastSavedAt: TimeInterval

        init(
            coins: Int,
            candy: Int,
            keys: Int,
            bestStreak: Int,
            totalTaps: Int,
            totalDamage: Double,
            lastLevelId: Int,
            lastSavedAt: TimeInterval
        ) {
            self.coins = max(0, coins)
            self.candy = max(0, candy)
            self.keys = max(0, keys)
            self.bestStreak = max(0, bestStreak)
            self.totalTaps = max(0, totalTaps)
            self.totalDamage = max(0, totalDamage)
            self.lastLevelId = max(1, lastLevelId)
            self.lastSavedAt = max(0, lastSavedAt)
        }

        static func fresh() -> Snapshot {
            Snapshot(
                coins: 0,
                candy: 0,
                keys: 0,
                bestStreak: 0,
                totalTaps: 0,
                totalDamage: 0,
                lastLevelId: 1,
                lastSavedAt: 0
            )
        }
    }

    @Published private(set) var snapshot: Snapshot = .fresh()
    @Published private(set) var statusLine: String = "Empty"

    private let key = "boniata.pinata.progress"
    private var bag = Set<AnyCancellable>()

    init() {
        load()
        refreshStatus()
    }

    func load() {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: key) else {
            snapshot = .fresh()
            refreshStatus()
            return
        }

        do {
            let decoded = try JSONDecoder().decode(Snapshot.self, from: data)
            snapshot = decoded
        } catch {
            snapshot = .fresh()
        }

        refreshStatus()
    }

    func save(from state: PinataBoardState, levelId: Int) {
        let snap = Snapshot(
            coins: state.coins,
            candy: state.candy,
            keys: state.keys,
            bestStreak: state.streakBest,
            totalTaps: state.tapsTotal,
            totalDamage: state.damageTotal,
            lastLevelId: levelId,
            lastSavedAt: Date().timeIntervalSince1970
        )

        snapshot = snap
        persist(snap)
        refreshStatus()
    }

    func mergeCoins(_ add: Int) {
        let delta = max(0, add)
        let next = Snapshot(
            coins: snapshot.coins + delta,
            candy: snapshot.candy,
            keys: snapshot.keys,
            bestStreak: snapshot.bestStreak,
            totalTaps: snapshot.totalTaps,
            totalDamage: snapshot.totalDamage,
            lastLevelId: snapshot.lastLevelId,
            lastSavedAt: Date().timeIntervalSince1970
        )
        snapshot = next
        persist(next)
        refreshStatus()
    }

    func resetAll() {
        snapshot = .fresh()
        UserDefaults.standard.removeObject(forKey: key)
        refreshStatus()
    }

    // MARK: - Internals

    private func persist(_ value: Snapshot) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private func refreshStatus() {
        let s = snapshot
        if s.lastSavedAt <= 0 {
            statusLine = "Empty"
            return
        }

        let c = s.coins
        let k = s.keys
        let st = s.bestStreak
        statusLine = "Coins \(c) • Keys \(k) • Best \(st)"
    }
}
