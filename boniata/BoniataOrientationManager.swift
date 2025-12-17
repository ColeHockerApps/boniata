import SwiftUI
import Combine
import UIKit

@MainActor
final class BoniataOrientationManager: ObservableObject {
    static let shared = BoniataOrientationManager()

    enum Mode {
        case flexible
        case portrait
        case landscape
    }

    @Published private(set) var mode: Mode = .flexible
    @Published private(set) var activeValue: URL? = nil

    private init() {}

    func allowFlexible() {
        mode = .flexible
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func lockPortrait() {
        mode = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func lockLandscape() {
        mode = .landscape
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func setActiveValue(_ value: URL?) {
        activeValue = normalizeTrailingSlash(value)
    }

    private func normalizeTrailingSlash(_ url: URL?) -> URL? {
        guard let url else { return nil }

        let scheme = url.scheme?.lowercased() ?? ""
        guard scheme == "http" || scheme == "https" else { return url }

        guard var c = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return url }

        // Remove trailing "/" from path ("/boniatatwelve/" -> "/boniatatwelve").
        // Keep "/" as-is.
        if c.path.count > 1, c.path.hasSuffix("/") {
            while c.path.count > 1, c.path.hasSuffix("/") {
                c.path.removeLast()
            }
        }

        return c.url ?? url
    }

    var interfaceMask: UIInterfaceOrientationMask {
        switch mode {
        case .flexible:
            return [.portrait, .landscapeLeft, .landscapeRight]
        case .portrait:
            return [.portrait]
        case .landscape:
            return [.landscapeLeft, .landscapeRight]
        }
    }
}
