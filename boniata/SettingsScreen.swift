import SwiftUI
import Combine

struct SettingsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var haptics: HapticsManager
    @EnvironmentObject private var paths: BoniataPaths
    @Environment(\.openURL) private var openURL

    @AppStorage(BoniataAssets.Tokens.settingsSoundsKey) private var soundsEnabled: Bool = true
    @AppStorage(BoniataAssets.Tokens.settingsHapticsKey) private var hapticsEnabledValue: Bool = true

    @State private var showResetAlert: Bool = false

    var body: some View {
        ZStack {
            BoniataTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 18) {
                        gameSection
                        infoSection
                        resetSection
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 26)
                }
            }
        }
        .onAppear {
            haptics.setEnabled(hapticsEnabledValue)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                if hapticsEnabledValue { haptics.tap() }
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle().fill(Color.black.opacity(0.45))
                    )
            }

            Spacer()

            Text("Settings")
                .font(BoniataTheme.Fonts.title(20))
                .foregroundColor(BoniataTheme.Colors.textPrimary)

            Spacer()

            Color.clear
                .frame(width: 34, height: 34)
        }
        .padding(.horizontal, 18)
        .padding(.top, 18)
        .padding(.bottom, 10)
        .background(
            Color.black.opacity(0.28)
                .ignoresSafeArea(edges: .top)
        )
    }

    private var gameSection: some View {
        BoniataComponents.GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Game")
                    .font(BoniataTheme.Fonts.subtitle(14))
                    .foregroundColor(BoniataTheme.Colors.textSecondary)

                toggleRow(
                    title: "Sound",
                    subtitle: "Control in-game sound effects.",
                    isOn: $soundsEnabled
                )

                toggleRow(
                    title: "Haptics",
                    subtitle: "Vibration feedback on taps and actions.",
                    isOn: $hapticsEnabledValue
                )
            }
        }
    }

    private var infoSection: some View {
        BoniataComponents.GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Info")
                    .font(BoniataTheme.Fonts.subtitle(14))
                    .foregroundColor(BoniataTheme.Colors.textSecondary)

                Button {
                    if hapticsEnabledValue { haptics.tap() }
                    openURL(paths.privacyPoint)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(BoniataTheme.Colors.redPrimary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Privacy Policy")
                                .font(BoniataTheme.Fonts.body(14))
                                .foregroundColor(BoniataTheme.Colors.textPrimary)

                            Text("Read the rules of the road.")
                                .font(BoniataTheme.Fonts.body(12))
                                .foregroundColor(BoniataTheme.Colors.textMuted)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(BoniataTheme.Colors.textMuted)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.black.opacity(0.55))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(BoniataTheme.Colors.borderSoft, lineWidth: 1)
                            )
                    )
                }
            }
        }
    }

    private var resetSection: some View {
        BoniataComponents.GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Session")
                    .font(BoniataTheme.Fonts.subtitle(14))
                    .foregroundColor(BoniataTheme.Colors.textSecondary)

                Text("You can reset saved progress stored on this device.")
                    .font(BoniataTheme.Fonts.body(12))
                    .foregroundColor(BoniataTheme.Colors.textMuted)

                Button {
                    if hapticsEnabledValue { haptics.press() }
                    showResetAlert = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Reset Local Progress")
                            .font(BoniataTheme.Fonts.body(14))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(BoniataTheme.Colors.redPrimary.opacity(0.9))
                            .shadow(color: BoniataTheme.Colors.glow, radius: 14, x: 0, y: 0)
                    )
                }
                .buttonStyle(.plain)
                .alert("Reset progress?", isPresented: $showResetAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Reset", role: .destructive) {
                        resetLocal()
                    }
                } message: {
                    Text("This will clear saved progress on this device.")
                }
            }
        }
    }

    private func toggleRow(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BoniataTheme.Fonts.body(15))
                    .foregroundColor(BoniataTheme.Colors.textPrimary)

                Text(subtitle)
                    .font(BoniataTheme.Fonts.body(12))
                    .foregroundColor(BoniataTheme.Colors.textMuted)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(BoniataTheme.Colors.redPrimary)
        }
    }

    private func resetLocal() {
        UserDefaults.standard.removeObject(forKey: BoniataAssets.Tokens.trailKey)
        UserDefaults.standard.removeObject(forKey: BoniataAssets.Tokens.marksKey)
    }
}
