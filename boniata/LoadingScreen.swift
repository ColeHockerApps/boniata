import SwiftUI
import Combine

struct LoadingScreen: View {
    let onFinish: () -> Void

    @State private var progress: Double = 0
    @State private var isVisible: Bool = true

    @State private var driftA: CGFloat = -0.18
    @State private var driftB: CGFloat = 0.22
    @State private var driftC: CGFloat = -0.12

    @State private var shimmer: CGFloat = -0.9
    @State private var pulse: Bool = false

    @State private var spin: Double = 0
    @State private var orbit: Bool = false

    private let total = BoniataAssets.Motion.loadingDuration
    private let centerCount = 16

    var body: some View {
        ZStack {
            BoniataTheme.backgroundGradient
                .ignoresSafeArea()

            ambientLayer
            centerKineticLayer

            VStack(spacing: 18) {
                Spacer()

                progressCard
                    .padding(.horizontal, 22)
                    .padding(.bottom, 28)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .animation(.easeOut(duration: BoniataAssets.Motion.fadeOutDuration), value: isVisible)
        .onAppear {
            start()
        }
    }

    // MARK: - Ambient

    private var ambientLayer: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.25)

                softBlob(
                    size: min(geo.size.width, geo.size.height) * 0.92,
                    x: geo.size.width * 0.18,
                    y: geo.size.height * 0.22,
                    colorA: BoniataTheme.Colors.redGlow.opacity(0.38),
                    colorB: BoniataTheme.Colors.emberSoft.opacity(0.18),
                    drift: driftA
                )

                softBlob(
                    size: min(geo.size.width, geo.size.height) * 0.72,
                    x: geo.size.width * 0.78,
                    y: geo.size.height * 0.36,
                    colorA: BoniataTheme.Colors.redPrimary.opacity(0.32),
                    colorB: BoniataTheme.Colors.ember.opacity(0.16),
                    drift: driftB
                )

                softBlob(
                    size: min(geo.size.width, geo.size.height) * 0.62,
                    x: geo.size.width * 0.42,
                    y: geo.size.height * 0.72,
                    colorA: BoniataTheme.Colors.glow.opacity(0.34),
                    colorB: BoniataTheme.Colors.redPrimary.opacity(0.12),
                    drift: driftC
                )

                vignette
            }
            .ignoresSafeArea()
        }
    }

    private func softBlob(
        size: CGFloat,
        x: CGFloat,
        y: CGFloat,
        colorA: Color,
        colorB: Color,
        drift: CGFloat
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [colorA, colorB, Color.clear],
                    center: .center,
                    startRadius: 4,
                    endRadius: size * 0.55
                )
            )
            .frame(width: size, height: size)
            .position(x: x, y: y)
            .scaleEffect(pulse ? 1.05 : 0.96)
            .offset(x: drift * 160, y: drift * 120)
            .blur(radius: 22)
            .blendMode(.screen)
            .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: pulse)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: driftA)
    }

    private var vignette: some View {
        Rectangle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.25),
                        Color.black.opacity(0.55)
                    ],
                    center: .center,
                    startRadius: 140,
                    endRadius: 620
                )
            )
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }

    // MARK: - Center kinetic

    private var centerKineticLayer: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width * 0.5, y: geo.size.height * 0.44)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                BoniataTheme.Colors.redGlow.opacity(0.28),
                                BoniataTheme.Colors.redPrimary.opacity(0.10),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 6,
                            endRadius: side * 0.26
                        )
                    )
                    .frame(width: side * 0.56, height: side * 0.56)
                    .position(center)
                    .scaleEffect(pulse ? 1.03 : 0.97)
                    .blur(radius: 10)
                    .blendMode(.screen)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)

                ForEach(0..<centerCount, id: \.self) { i in
                    let a = Double(i) / Double(centerCount) * 2.0 * Double.pi
                    let baseR = side * 0.18
                    let wobble = (Double(i % 5) - 2.0) * 0.006
                    let r = baseR * (1.0 + CGFloat(wobble)) * (orbit ? 1.02 : 0.98)

                    CenterShard(index: i, progress: progress)
                        .position(
                            x: center.x + cos(a + spin) * r,
                            y: center.y + sin(a + spin) * r
                        )
                        .opacity(orbit ? 1.0 : 0.92)
                }
            }
            .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: orbit)
        }
        .allowsHitTesting(false)
    }

    // MARK: - Progress card

    private var progressCard: some View {
        VStack(spacing: 14) {
            progressBar
            thinGlowLine
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: BoniataTheme.Layout.corner, style: .continuous)
                .fill(BoniataTheme.Colors.surfaceStrong)
                .overlay(
                    RoundedRectangle(cornerRadius: BoniataTheme.Layout.corner, style: .continuous)
                        .stroke(BoniataTheme.Colors.borderSoft, lineWidth: 1)
                )
                .shadow(color: BoniataTheme.Colors.shadow, radius: 14, x: 0, y: 10)
                .shadow(color: BoniataTheme.Colors.glow.opacity(0.9), radius: 20, x: 0, y: 0)
        )
    }

    private var progressBar: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                    .fill(Color.white.opacity(0.08))

                RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                BoniataTheme.Colors.redPrimary.opacity(0.95),
                                BoniataTheme.Colors.redGlow.opacity(0.95),
                                BoniataTheme.Colors.emberSoft.opacity(0.85)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(10, w * progress))
                    .overlay(shimmerOverlay(height: h))
                    .shadow(color: BoniataTheme.Colors.glow, radius: 14, x: 0, y: 0)

                RoundedRectangle(cornerRadius: h / 2, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            }
            .animation(.easeInOut(duration: 0.18), value: progress)
        }
        .frame(height: 14)
    }

    private func shimmerOverlay(height: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.22),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .rotationEffect(.degrees(18))
            .offset(x: shimmer * 220, y: 0)
            .blendMode(.screen)
            .mask(
                RoundedRectangle(cornerRadius: height / 2, style: .continuous)
            )
            .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: false), value: shimmer)
            .allowsHitTesting(false)
    }

    private var thinGlowLine: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.0),
                        BoniataTheme.Colors.redGlow.opacity(0.55),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 2)
            .opacity(pulse ? 1.0 : 0.65)
            .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
    }

    // MARK: - Timeline

    private func start() {
        pulse = true
        orbit = true

        withAnimation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true)) {
            driftA = 0.22
            driftB = -0.18
            driftC = 0.16
        }

        withAnimation(.linear(duration: 4.4).repeatForever(autoreverses: false)) {
            spin = Double.pi * 2.0
        }

        shimmer = 0.9

        let steps = 45
        let interval = total / Double(steps)

        var current = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            current += 1

            let t = min(1.0, Double(current) / Double(steps))
            let eased = t < 0.85 ? (t / 0.85) : (0.96 + (t - 0.85) * 0.04 / 0.15)
            progress = min(1.0, max(0.0, eased))

            if current >= steps {
                timer.invalidate()
                finish()
            }
        }
    }

    private func finish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            isVisible = false
            DispatchQueue.main.asyncAfter(deadline: .now() + BoniataAssets.Motion.fadeOutDuration) {
                onFinish()
            }
        }
    }
}

// MARK: - Center shard view (not nested)

private struct CenterShard: View {
    let index: Int
    let progress: Double

    var body: some View {
        let t = max(0.0, min(1.0, progress))
        let size = CGFloat(10 + (index % 4) * 4)
        let stretch = CGFloat(1.2 + Double(index % 3) * 0.18)
        let local = max(0.15, min(1.0, t + Double(index) * 0.02))

        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        BoniataTheme.Colors.redPrimary.opacity(0.95),
                        BoniataTheme.Colors.redGlow.opacity(0.80),
                        BoniataTheme.Colors.emberSoft.opacity(0.55)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: size * stretch, height: size)
            .rotationEffect(.degrees(Double(index * 27) + local * 140))
            .shadow(color: BoniataTheme.Colors.glow.opacity(0.85), radius: 10, x: 0, y: 0)
            .opacity(0.25 + local * 0.75)
            .scaleEffect(0.85 + local * 0.25)
    }
}
