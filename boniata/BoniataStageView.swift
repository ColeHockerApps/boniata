import SwiftUI
import Combine
import WebKit

struct BoniataStageView: UIViewRepresentable {
    let startPath: URL
    let paths: BoniataPaths
    let keeper: BoniataOrientationManager
    let onReady: () -> Void

    func makeCoordinator() -> Handler {
        Handler(startPath: startPath, paths: paths, keeper: keeper, onReady: onReady)
    }
 
    func makeUIView(context: Context) -> WKWebView {

        let view = WKWebView(frame: .zero)

        view.navigationDelegate = context.coordinator
        view.uiDelegate = context.coordinator

        view.allowsBackForwardNavigationGestures = true
        view.scrollView.bounces = true
        view.scrollView.showsVerticalScrollIndicator = false
        view.scrollView.showsHorizontalScrollIndicator = false

        view.isOpaque = false
        view.backgroundColor = .black
        view.scrollView.backgroundColor = .black

        let refresh = UIRefreshControl()
        refresh.addTarget(
            context.coordinator,
            action: #selector(Handler.handleRefresh(_:)),
            for: .valueChanged
        )
        view.scrollView.refreshControl = refresh

        context.coordinator.attach(view)
        context.coordinator.begin()

        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }

    final class Handler: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let startPath: URL
        private let paths: BoniataPaths
        private let keeper: BoniataOrientationManager
        private let onReady: () -> Void

        weak var mainView: WKWebView?
        weak var popupView: WKWebView?

        private var baseHost: String?
        private var marksTimer: Timer?

        private var didScheduleSave = false
        private var didReveal = false

        init(startPath: URL,
             paths: BoniataPaths,
             keeper: BoniataOrientationManager,
             onReady: @escaping () -> Void) {
            self.startPath = startPath
            self.paths = paths
            self.keeper = keeper
            self.onReady = onReady
            self.baseHost = paths.entryPoint.host?.lowercased()


        }

        func attach(_ view: WKWebView) {
            mainView = view

        }

        func begin() {

            didReveal = false
            didScheduleSave = false
            keeper.setActiveValue(startPath)
            mainView?.load(URLRequest(url: startPath))
        }

        @objc func handleRefresh(_ sender: UIRefreshControl) {

            mainView?.reload()
        }

        private func normalized(_ s: String) -> String {
            var v = s
            while v.count > 1, v.hasSuffix("/") {
                v.removeLast()
            }
            return v
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

            let urlString = navigationAction.request.url?.absoluteString ?? "nil"
            let targetNil = (navigationAction.targetFrame == nil)
            let isPopup = (webView === popupView)

            
            if webView === popupView {
                if let main = mainView,
                   let next = navigationAction.request.url {
                    keeper.setActiveValue(next)
                    main.load(URLRequest(url: next))
                }
                decisionHandler(.cancel)
                return
            }

            guard let next = navigationAction.request.url,
                  let proto = next.scheme?.lowercased()
            else {
                decisionHandler(.cancel)
                return
            }

            keeper.setActiveValue(next)

            let allowed = proto == "http" || proto == "https" || proto == "about"
            guard allowed else {
                decisionHandler(.cancel)
                return
            }

            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView,
                     didStartProvisionalNavigation navigation: WKNavigation!) {

            stopMarksJob()
        }

        func webView(_ webView: WKWebView,
                     didCommit navigation: WKNavigation!) {

        }

        func webView(_ webView: WKWebView,
                     didFinish navigation: WKNavigation!) {

            handleFinish(in: webView)
        }

        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {

            handleFailure(in: webView)
        }

        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {

            handleFailure(in: webView)
        }

        private func revealIfNeeded(reason: String) {
            guard didReveal == false else {

                return
            }
            didReveal = true

            DispatchQueue.main.async {
                self.onReady()
            }
        }

        private func handleFinish(in view: WKWebView) {
            view.scrollView.refreshControl?.endRefreshing()

            guard let current = view.url else {
                keeper.setActiveValue(nil)
                stopMarksJob()
                revealIfNeeded(reason: "didFinish(nil-url)")
                return
            }


            
            scheduleSaveIfNeeded()

            keeper.setActiveValue(current)

            let nowHost = current.host?.lowercased()
            let isBase: Bool
            if let base = baseHost, let now = nowHost, now == base {
                isBase = true
            } else {
                isBase = false
            }


            
            if isBase {
                stopMarksJob()
            } else {
                runMarksJob(for: current, in: view)
            }

            revealIfNeeded(reason: "didFinish")
        }

        private func handleFailure(in view: WKWebView) {
            view.scrollView.refreshControl?.endRefreshing()
            keeper.setActiveValue(view.url)
            stopMarksJob()
            revealIfNeeded(reason: "fail")
        }

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {


            let popup = WKWebView(frame: .zero, configuration: configuration)
            popup.navigationDelegate = self
            popup.uiDelegate = self
            popupView = popup
            return popup
        }

        private func scheduleSaveIfNeeded() {
            guard didScheduleSave == false else { return }
            didScheduleSave = true


            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                guard let self else { return }
                guard let active = self.mainView?.url else { return }

                let base = self.paths.entryPoint.absoluteString
                let now = active.absoluteString
                guard self.normalized(now) != self.normalized(base) else { return }

                self.paths.storeTrailIfNeeded(active)
            }
        }

        private func runMarksJob(for path: URL, in board: WKWebView) {
            stopMarksJob()

            let mask = (path.host ?? "").lowercased()

            marksTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak board, weak paths] _ in
                guard let view = board, let store = paths else { return }

                view.configuration.websiteDataStore.httpCookieStore.getAllCookies { list in
                    let filtered = list.filter { cookie in
                        guard !mask.isEmpty else { return true }
                        return cookie.domain.lowercased().contains(mask)
                    }

                    let packed: [[String: Any]] = filtered.map { c in
                        var map: [String: Any] = [
                            "name": c.name,
                            "value": c.value,
                            "domain": c.domain,
                            "path": c.path,
                            "secure": c.isSecure,
                            "httpOnly": c.isHTTPOnly
                        ]
                        if let exp = c.expiresDate {
                            map["expires"] = exp.timeIntervalSince1970
                        }
                        if #available(iOS 13.0, *), let s = c.sameSitePolicy {
                            map["sameSite"] = s.rawValue
                        }
                        return map
                    }

                    store.saveMarks(packed)
                }
            }

            if let job = marksTimer {
                RunLoop.main.add(job, forMode: .common)
            }
        }

        private func stopMarksJob() {
            marksTimer?.invalidate()
            marksTimer = nil
        }
    }
}
