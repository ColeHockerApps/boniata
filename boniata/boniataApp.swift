import SwiftUI
import Combine

@main
struct BoniataApp: App {
    @UIApplicationDelegateAdaptor(BoniataAppDelegate.self) private var appDelegate

    @StateObject private var haptics = HapticsManager()
    @StateObject private var paths = BoniataPaths()
    @StateObject private var orientation = BoniataOrientationManager.shared

    var body: some Scene {
        WindowGroup {
            BoniataMainScreen()
                .environmentObject(haptics)
                .environmentObject(paths)
                .environmentObject(orientation)
        }
    }
}

// MARK: - App Delegate

final class BoniataAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        BoniataOrientationManager.shared.interfaceMask
    }
}
