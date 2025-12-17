import SwiftUI
import Combine
import UIKit

@MainActor
final class HapticsManager: ObservableObject {

    @Published var isEnabled: Bool = true

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)

    private let notify = UINotificationFeedbackGenerator()
    private let select = UISelectionFeedbackGenerator()

    init() {
        warmUp()
    }

    func warmUp() {
        guard isEnabled else { return }
        light.prepare()
        medium.prepare()
        heavy.prepare()
        notify.prepare()
        select.prepare()
    }

    func tap() {
        guard isEnabled else { return }
        light.impactOccurred(intensity: 0.85)
        light.prepare()
    }

    func soft() {
        guard isEnabled else { return }
        light.impactOccurred(intensity: 0.55)
        light.prepare()
    }

    func press() {
        guard isEnabled else { return }
        medium.impactOccurred(intensity: 0.9)
        medium.prepare()
    }

    func win() {
        guard isEnabled else { return }
        notify.notificationOccurred(.success)
        notify.prepare()
    }

    func warn() {
        guard isEnabled else { return }
        notify.notificationOccurred(.warning)
        notify.prepare()
    }

    func fail() {
        guard isEnabled else { return }
        notify.notificationOccurred(.error)
        notify.prepare()
    }

    func pick() {
        guard isEnabled else { return }
        select.selectionChanged()
        select.prepare()
    }

    func setEnabled(_ value: Bool) {
        isEnabled = value
        if value {
            warmUp()
        }
    }
}
