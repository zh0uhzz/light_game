import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @EnvironmentObject private var audioManager: AudioManager
    @EnvironmentObject private var localization: LocalizationManager
    @EnvironmentObject private var premiumUnlock: PremiumUnlockService

    private var lang: AppContentLanguage { localization.content }
    @State private var showResetAlert = false
    @State private var showImportSheet = false
    @State private var importPasteText = ""
    @State private var importErrorMessage: String?
    @State private var exportCopiedNotice = false
    @State private var showPremiumSheet = false
    @State private var isRestoringPremium = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                NavigationLink {
                    AchievementsListView()
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "trophy.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.96, blue: 0.78),
                                        Color(red: 1.0, green: 0.82, blue: 0.45),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(color: Color(red: 1.0, green: 0.88, blue: 0.45).opacity(0.35), radius: 3, y: 0)
                        Text(AppLocalizedStrings.achievementsRowTitle(lang))
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.95))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(cardBackground)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(TapGesture().onEnded { audioManager.playClick() })

                personalSection
                premiumSection
                gameSettingsSection
                dataSection
            }
            .padding()
            .frame(maxWidth: 720, alignment: .leading)
            .frame(maxWidth: .infinity)
        }
        .scrollContentBackground(.hidden)
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color(red: 0.08, green: 0.08, blue: 0.11)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                FireflyBackgroundView(fireflyCount: 16, luminosity: 0.48)
            }
            .ignoresSafeArea()
        )
        .navigationTitle(AppLocalizedStrings.settingsTitle(lang))
        .alert(AppLocalizedStrings.resetConfirmTitle(lang), isPresented: $showResetAlert) {
            Button(AppLocalizedStrings.resetConfirmDestructive(lang), role: .destructive) {
                audioManager.playClick()
                progressStore.resetAllProgress()
            }
            Button(AppLocalizedStrings.cancel(lang), role: .cancel) {
                audioManager.playClick()
            }
        } message: {
            Text(AppLocalizedStrings.resetWarningMessage(lang))
        }
        .alert(AppLocalizedStrings.importFailedTitle(lang), isPresented: Binding(
            get: { importErrorMessage != nil },
            set: { if !$0 { importErrorMessage = nil } }
        )) {
            Button(AppLocalizedStrings.ok(lang), role: .cancel) { importErrorMessage = nil }
        } message: {
            Text(importErrorMessage ?? "")
        }
        .sheet(isPresented: $showImportSheet) {
            importProgressSheet
        }
        .sheet(isPresented: $showPremiumSheet) {
            PremiumPaywallView()
                .environmentObject(premiumUnlock)
                .environmentObject(audioManager)
                .environmentObject(localization)
        }
        .overlay(alignment: .center) {
            if exportCopiedNotice {
                Text(AppLocalizedStrings.copiedToast(lang))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial, in: Capsule())
                    .transition(.opacity)
            }
        }
    }

    private var premiumSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppLocalizedStrings.premiumSectionTitle(lang))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.88))
            VStack(alignment: .leading, spacing: 10) {
                Text(
                    premiumUnlock.isUnlocked
                        ? AppLocalizedStrings.premiumMemberActive(lang)
                        : AppLocalizedStrings.premiumMemberInactive(lang)
                )
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))

                Button {
                    audioManager.playClick()
                    showPremiumSheet = true
                } label: {
                    Label(AppLocalizedStrings.premiumOpenPaywall(lang), systemImage: "cart.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .tint(.yellow)

                Button {
                    audioManager.playClick()
                    Task {
                        isRestoringPremium = true
                        await premiumUnlock.restorePurchases()
                        isRestoringPremium = false
                    }
                } label: {
                    Label(AppLocalizedStrings.premiumRestore(lang), systemImage: "arrow.clockwise.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .tint(.white.opacity(0.55))
                .disabled(isRestoringPremium)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)
        }
    }

    private var personalSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppLocalizedStrings.personalSection(lang))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.88))
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.85))
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppLocalizedStrings.localPlayer(lang))
                        .font(.subheadline.weight(.semibold))
                    Text(AppLocalizedStrings.progressSummary(lang, main: progressStore.mainCampaignCompletedCount, inf: progressStore.infiniteLevelsCleared))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(cardBackground)

            VStack(spacing: 10) {
                Button {
                    audioManager.playClick()
                    let s = progressStore.exportProgressToken()
                    guard !s.isEmpty else { return }
                    UIPasteboard.general.string = s
                    withAnimation(.easeInOut(duration: 0.2)) { exportCopiedNotice = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        withAnimation { exportCopiedNotice = false }
                    }
                } label: {
                    Label(AppLocalizedStrings.exportProgress(lang), systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .tint(.yellow)

                Button {
                    audioManager.playClick()
                    importPasteText = ""
                    showImportSheet = true
                } label: {
                    Label(AppLocalizedStrings.importProgress(lang), systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .tint(.cyan.opacity(0.9))
            }
            .padding(14)
            .background(cardBackground)
        }
    }

    private var importProgressSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text(AppLocalizedStrings.importSheetHint(lang))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextEditor(text: $importPasteText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(10)
                    .frame(minHeight: 160)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.08)))
                Spacer(minLength: 0)
            }
            .padding()
            .background(Color(red: 0.14, green: 0.1, blue: 0.09).ignoresSafeArea())
            .navigationTitle(AppLocalizedStrings.importSheetTitle(lang))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppLocalizedStrings.importClose(lang)) {
                        audioManager.playClick()
                        showImportSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(AppLocalizedStrings.importSave(lang)) {
                        audioManager.playClick()
                        do {
                            try progressStore.importProgressToken(importPasteText)
                            showImportSheet = false
                        } catch {
                            importErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                        }
                    }
                    .disabled(importPasteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private var gameSettingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppLocalizedStrings.gameSettingsSection(lang))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.88))
            VStack(spacing: 10) {
                Toggle(AppLocalizedStrings.bgmToggle(lang), isOn: Binding(
                    get: { !audioManager.isMuted },
                    set: { isOn in
                        audioManager.playClick()
                        audioManager.setMuted(!isOn)
                    }
                ))
                .tint(.yellow)

                VStack(alignment: .leading, spacing: 6) {
                    Text(AppLocalizedStrings.languageSectionTitle(lang))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    Picker("", selection: Binding(
                        get: { localization.preference },
                        set: { newVal in
                            audioManager.playClick()
                            localization.setPreference(newVal)
                        }
                    )) {
                        ForEach(LanguagePreference.allCases) { pref in
                            Text(AppLocalizedStrings.languagePreferenceLabel(pref, content: lang)).tag(pref)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(.yellow)
                    Text(AppLocalizedStrings.languageSectionFootnote(lang))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.45))
                }

                Button {
                    audioManager.playClick()
                    NotificationCenter.default.post(name: .lightGameReplayOnboardingIntro, object: nil)
                } label: {
                    Label(AppLocalizedStrings.replayOnboarding(lang), systemImage: "sparkles.rectangle.stack")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.bordered)
                .tint(.white.opacity(0.75))
            }
            .padding(14)
            .background(cardBackground)
        }
    }

    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppLocalizedStrings.dataSection(lang))
                .font(.headline)
                .foregroundStyle(.white.opacity(0.88))
            Button(role: .destructive) {
                audioManager.playClick()
                showResetAlert = true
            } label: {
                Text(AppLocalizedStrings.resetAllProgress(lang))
                    .frame(maxWidth: .infinity)
            }
            .padding(14)
            .background(cardBackground)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
