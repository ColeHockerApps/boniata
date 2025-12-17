import SwiftUI
import Combine

struct BoniataMainScreen: View {
    @EnvironmentObject private var haptics: HapticsManager
    @EnvironmentObject private var paths: BoniataPaths
    @EnvironmentObject private var keeper: BoniataOrientationManager

    @State private var showLoading: Bool = true
    @State private var showSettings: Bool = false

    var body: some View {
        ZStack {
            BoniataContainer()
                .environmentObject(paths)
                .environmentObject(keeper)

            VStack {
                HStack { Spacer() }
                Spacer()
            }
            .opacity(showLoading ? 0.0 : 1.0)
            .animation(.easeOut(duration: 0.25), value: showLoading)

            if showLoading {
                LoadingScreen {

                    finishLoading()
                }
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsScreen()
                .environmentObject(haptics)
                .environmentObject(paths)
        }
        .onAppear {

            keeper.allowFlexible()
        }
        .onChange(of: showLoading) { v in

        }
        .onReceive(keeper.$activeValue) { next in

        }
    }

    private func normalized(_ s: String) -> String {
        var v = s
        while v.count > 1, v.hasSuffix("/") {
            v.removeLast()
        }
        return v
    }

    private func finishLoading() {

        withAnimation(.easeOut(duration: 0.25)) {
            showLoading = false
        }

        let base = paths.entryPoint.absoluteString

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let current = keeper.activeValue?.absoluteString

            guard let current else { return }

            guard normalized(current) == normalized(base) else { return }

            keeper.lockPortrait()

        }
    }
}
