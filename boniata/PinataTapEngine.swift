import Foundation
import Combine
import SwiftUI

@MainActor
final class PinataTapEngine: ObservableObject {

    @Published private(set) var state: PinataBoardState
    @Published private(set) var level: PinataLevelConfig

    private var lastTapTime: TimeInterval = 0
    private var bag = Set<AnyCancellable>()

    init() {
        self.state = PinataBoardState()
        self.level = PinataLevelConfig.warmUp(1)
        applyLevel(self.level)
    }

    init(level: PinataLevelConfig) {
        self.state = PinataBoardState()
        self.level = level
        applyLevel(level)
    }

    init(state: PinataBoardState, level: PinataLevelConfig) {
        self.state = state
        self.level = level
        applyLevel(level)
    }

    func applyLevel(_ config: PinataLevelConfig) {
        level = config
        state.resetAllProgress()
        state.startSession()
    }

    func tap() {
        guard state.isActive else { return }

        let now = Date().timeIntervalSince1970
        let cooldown = Double(level.streakWindowMs) / 1000.0 * 0.15

        if now - lastTapTime < cooldown { return }

        lastTapTime = now
        state.simulateTap()

        if state.pinataHealth <= 0 {
            endRound()
        }
    }

    func heavyTap(multiplier: Double) {
        guard state.isActive else { return }

        let now = Date().timeIntervalSince1970
        let cooldown = Double(level.streakWindowMs) / 1000.0 * 0.25

        if now - lastTapTime < cooldown { return }

        lastTapTime = now
        state.simulateTap()

        if multiplier > 1.0 {
            state.simulateTap()
        }

        if state.pinataHealth <= 0 {
            endRound()
        }
    }

    func burst(count: Int) {
        guard state.isActive else { return }

        let c = min(max(1, count), 8)
        for _ in 0..<c {
            state.simulateTap()
            if state.pinataHealth <= 0 { break }
        }

        if state.pinataHealth <= 0 {
            endRound()
        }
    }

    func dropBonus() {
        guard state.isActive else { return }
        state.simulateDrop()
    }

    func endRound() {
        state.stopSession()
    }

    func restart() {
        state.resetAllProgress()
        state.startSession()
    }

    func injectReward(_ reward: PinataModels.Reward) {
        state.simulateDrop()
    }

    func injectBooster(_ booster: PinataModels.Booster) {
        state.simulateDrop()
    }
}
