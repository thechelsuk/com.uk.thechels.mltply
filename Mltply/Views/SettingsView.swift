import SwiftUI

struct SettingsView: View {
    @Binding var appColorScheme: AppColorScheme
    @Binding var mathOperations: MathOperationSettings
    @Binding var continuousMode: Bool
    @Binding var timerDuration: Int
    @Binding var soundEnabled: Bool
    @Binding var questionMode: QuestionMode
    @Binding var practiceSettings: PracticeSettings
    @ObservedObject var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingClearHistoryAlert = false
    @State private var showingClearScoresAlert = false
    @State private var showingClearAchievementsAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    HStack {
                        Text("Theme")
                        Spacer()
                        Picker("Theme", selection: $appColorScheme) {
                            ForEach(AppColorScheme.allCases) { scheme in
                                Image(systemName: scheme.iconName)
                                    .tag(scheme)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                }

                Section("Set Timer Options") {
                    Toggle("Continuous Mode", isOn: $continuousMode)
                    if !continuousMode {
                        HStack {
                            Text("Duration")
                            Slider(
                                value: Binding(
                                    get: { Double(timerDuration) }, set: { timerDuration = Int($0) }
                                ),
                                in: 1...10, step: 1
                            )
                            .accessibilityIdentifier("timerSlider")
                            Text("\(timerDuration)m")
                                .font(.headline)
                                .monospacedDigit()
                                .accessibilityIdentifier("timerDurationLabel")
                        }
                    }
                }

                Section("Math Configuration options") {
                    HStack {
                        Text("Question Order")
                        Spacer()
                        Picker("Order", selection: $questionMode) {
                            ForEach(QuestionMode.allCases) { mode in
                                Image(systemName: mode.iconName)
                                    .tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 80)
                    }
                    NavigationLink("Number Range") {
                        NumberSelectionView(practiceSettings: $practiceSettings)
                    }
                    NavigationLink("Select Math Operations") {
                        MathOperationsView(mathOperations: $mathOperations, questionMode: questionMode)
                    }
                }

                Section("Chat Options") {
                    Toggle("Enable Sound", isOn: $soundEnabled)
                    Button(role: .destructive) {
                        showingClearHistoryAlert = true
                    } label: {
                        Label("Clear Message History", systemImage: "trash")
                    }

                    Button(role: .destructive) {
                        showingClearScoresAlert = true
                    } label: {
                        Label("Clear All Scores", systemImage: "trash")
                    }

                    Button(role: .destructive) {
                        showingClearAchievementsAlert = true
                    } label: {
                        Label("Clear All Achievements", systemImage: "trash")
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Printable Workbooks", systemImage: "book.closed")
                            .font(.headline)
                        Text("Grown-ups: Printable Mltply maths workbooks for Years 1–7, with answers, are available at:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        // Verbatim so the address is plain text, never a tappable link
                        Text(verbatim: "shop.thechels.uk")
                            .font(.subheadline.bold())
                            .accessibilityIdentifier("workbooksShopAddress")
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                } header: {
                    Text("For Grown-ups")
                }

                Section("Legal") {
                    NavigationLink("Terms of Use") {
                        TermsView()
                    }

                    NavigationLink("Privacy Policy") {
                        PrivacyView()
                    }
                }

            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Clear Message History", isPresented: $showingClearHistoryAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearMessageHistory()
                }
            } message: {
                Text("This will permanently delete all chat messages. This action cannot be undone.")
            }
            .alert("Clear All Scores", isPresented: $showingClearScoresAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.scoreManager.clearAllScores()
                }
            } message: {
                Text("This will permanently delete all your high scores. This action cannot be undone.")
            }
            .alert("Clear All Achievements", isPresented: $showingClearAchievementsAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.achievementsManager.clearAllAchievements()
                    viewModel.questionHistory.clearHistory()
                }
            } message: {
                Text("This will permanently delete all your achievements and question history. This action cannot be undone.")
            }
            .onDisappear {
                viewModel.saveSettings()
            }
        }
    }
}

#Preview {
    SettingsView(
        appColorScheme: .constant(.system),
        mathOperations: .constant(MathOperationSettings()),
        continuousMode: .constant(true),
        timerDuration: .constant(2),
        soundEnabled: .constant(true),
        questionMode: .constant(.random),
        practiceSettings: .constant(PracticeSettings()),
        viewModel: QuizViewModel()
    )
}
