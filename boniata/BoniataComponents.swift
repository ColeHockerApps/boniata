import SwiftUI
import Combine

enum BoniataComponents {

    struct GlassCard<Content: View>: View {
        let content: Content

        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        var body: some View {
            content
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: BoniataTheme.Layout.corner, style: .continuous)
                        .fill(BoniataTheme.Colors.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: BoniataTheme.Layout.corner, style: .continuous)
                                .stroke(BoniataTheme.Colors.borderSoft, lineWidth: 1)
                        )
                        .shadow(color: BoniataTheme.Colors.shadow, radius: 14, x: 0, y: 10)
                        .shadow(color: BoniataTheme.Colors.glow.opacity(0.8), radius: 22, x: 0, y: 0)
                )
        }
    }

    struct PrimaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(BoniataTheme.Fonts.body(15))
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(BoniataTheme.Colors.redPrimary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.white.opacity(0.18), lineWidth: 1)
                        )
                )
                .shadow(color: BoniataTheme.Colors.glow, radius: 16, x: 0, y: 0)
                .shadow(color: BoniataTheme.Colors.shadow, radius: 14, x: 0, y: 10)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .opacity(configuration.isPressed ? 0.9 : 1.0)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
    }

    struct SecondaryButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(BoniataTheme.Fonts.body(14))
                .foregroundColor(BoniataTheme.Colors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.55))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(BoniataTheme.Colors.borderSoft, lineWidth: 1)
                        )
                )
                .shadow(color: BoniataTheme.Colors.shadow, radius: 10, x: 0, y: 8)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .opacity(configuration.isPressed ? 0.86 : 1.0)
                .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
        }
    }

    struct EmberTag: View {
        let text: String
        let icon: String?

        init(_ text: String, icon: String? = nil) {
            self.text = text
            self.icon = icon
        }

        var body: some View {
            HStack(spacing: 7) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(BoniataTheme.Colors.emberSoft)
                }

                Text(text)
                    .font(BoniataTheme.Fonts.body(11))
                    .foregroundColor(.white.opacity(0.92))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.black.opacity(0.52))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(BoniataTheme.Colors.borderSoft, lineWidth: 1)
                    )
            )
            .shadow(color: BoniataTheme.Colors.shadow, radius: 8, x: 0, y: 6)
        }
    }
}

extension ButtonStyle where Self == BoniataComponents.PrimaryButtonStyle {
    static var boniataPrimary: BoniataComponents.PrimaryButtonStyle { .init() }
}

extension ButtonStyle where Self == BoniataComponents.SecondaryButtonStyle {
    static var boniataSecondary: BoniataComponents.SecondaryButtonStyle { .init() }
}
