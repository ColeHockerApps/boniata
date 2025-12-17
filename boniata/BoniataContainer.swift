import SwiftUI
import Combine

struct BoniataContainer: View {
    @EnvironmentObject private var paths: BoniataPaths
    @EnvironmentObject private var keeper: BoniataOrientationManager

    @StateObject private var vm = BoniataContainerModel()

    var body: some View {
        ZStack {
            BoniataTheme.backgroundGradient
                .ignoresSafeArea()

            ZStack {
                Color.black.opacity(0.92)
                    .ignoresSafeArea()

                BoniataStageView(
                    startPath: paths.restoreStoredTrail() ?? paths.entryPoint,
                    paths: paths,
                    keeper: keeper
                ) {

                    vm.markReady()
                }
                .opacity(vm.fadeIn ? 1 : 0)
                .animation(.easeOut(duration: BoniataAssets.Motion.readyFadeInDuration), value: vm.fadeIn)

                if vm.isReady == false {
                    loadingOverlay
                }
            }

            Color.black
                .opacity(vm.dimLayer)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .animation(.easeOut(duration: 0.25), value: vm.dimLayer)
        }
        .onAppear {

            vm.onAppear()
        }
        .onChange(of: vm.isReady) { v in

        }
        .onChange(of: vm.fadeIn) { v in

        }
        .onChange(of: vm.dimLayer) { v in

        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.14)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.15)
                    .tint(BoniataTheme.Colors.redPrimary)

                Text("Preparing…")
                    .font(BoniataTheme.Fonts.body(14))
                    .foregroundColor(BoniataTheme.Colors.textSecondary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: BoniataTheme.Layout.corner, style: .continuous)
                    .fill(BoniataTheme.Colors.surfaceStrong)
                    .overlay(
                        RoundedRectangle(cornerRadius: BoniataTheme.Layout.corner, style: .continuous)
                            .stroke(BoniataTheme.Colors.borderSoft, lineWidth: 1)
                    )
                    .shadow(color: BoniataTheme.Colors.shadow, radius: 12, x: 0, y: 8)
                    .shadow(color: BoniataTheme.Colors.glow.opacity(0.9), radius: 18, x: 0, y: 0)
            )
        }
        .transition(.opacity)
        .animation(.easeOut(duration: 0.25), value: vm.isReady)
    }
}

// MARK: - Model

final class BoniataContainerModel: ObservableObject {
    @Published var isReady: Bool = false
    @Published var fadeIn: Bool = false
    @Published var dimLayer: Double = 1.0

    func onAppear() {

        isReady = false
        fadeIn = false
        dimLayer = 1.0

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.dimLayer = 0.0

        }
    }

    func markReady() {
        guard isReady == false else {

            return
        }
        isReady = true
        fadeIn = true

    }
}
