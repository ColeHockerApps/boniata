import Foundation
import Combine
import SwiftUI

final class BoniataPaths: ObservableObject {

    @Published var entryPoint: URL
    @Published var privacyPoint: URL

    private let entryKey = BoniataAssets.Tokens.entryKey
    private let privacyKey = BoniataAssets.Tokens.privacyKey
    private let trailKey = BoniataAssets.Tokens.trailKey
    private let marksKey = BoniataAssets.Tokens.marksKey

    private var hasStoredTrail = false

    init() {
        let defaults = UserDefaults.standard

        let defaultEntry = "https://oktaykaangames.github.io/gettwelve"
       // let defaultEntry = "https://doancongbang1991.github.io/mobileapp/mobile/gettwelve/"

        let defaultPrivacy = "https://example.com/privacy"

        if let saved = defaults.string(forKey: entryKey),
           let url = URL(string: saved) {
            entryPoint = url
        } else {
            entryPoint = URL(string: defaultEntry)!
        }

        if let saved = defaults.string(forKey: privacyKey),
           let url = URL(string: saved) {
            privacyPoint = url
        } else {
            privacyPoint = URL(string: defaultPrivacy)!
        }
    }

    func updateEntry(_ link: String) {
        guard let url = URL(string: link) else { return }
        entryPoint = url
        UserDefaults.standard.set(link, forKey: entryKey)
    }

    func updatePrivacy(_ link: String) {
        guard let url = URL(string: link) else { return }
        privacyPoint = url
        UserDefaults.standard.set(link, forKey: privacyKey)
    }

    func storeTrailIfNeeded(_ link: URL) {
        guard hasStoredTrail == false else { return }
        hasStoredTrail = true

        let defaults = UserDefaults.standard
        if defaults.string(forKey: trailKey) != nil {
            return
        }

        defaults.set(link.absoluteString, forKey: trailKey)
    }

    func restoreStoredTrail() -> URL? {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: trailKey),
           let url = URL(string: saved) {
            return url
        }
        return nil
    }

    func saveMarks(_ items: [[String: Any]]) {
        UserDefaults.standard.set(items, forKey: marksKey)
    }

    func currentMarks() -> [[String: Any]]? {
        UserDefaults.standard.array(forKey: marksKey) as? [[String: Any]]
    }
}
