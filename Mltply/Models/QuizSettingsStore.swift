import Foundation

/// Reads and writes the quiz's persisted settings, isolated from `QuizViewModel`
/// so the persistence logic can be tested independently of UI state and injected
/// with a non-standard `UserDefaults` in tests.
struct QuizSettingsStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    private enum Key {
        static let mathOperations = "mathOperationsSettings"
        static let practiceSettings = "practiceSettings"
        static let questionMode = "questionMode"
        static let continuousMode = "continuousMode"
        static let timerDuration = "timerDuration"
        static let soundEnabled = "soundEnabled"
        static let appColorScheme = "appColorScheme"
    }

    func loadMathOperations() -> MathOperationSettings? {
        guard let data = defaults.data(forKey: Key.mathOperations) else { return nil }
        do {
            return try JSONDecoder().decode(MathOperationSettings.self, from: data)
        } catch {
            AppLog.persistence.error("Failed to decode saved math operations, resetting: \(error.localizedDescription)")
            return nil
        }
    }

    func save(mathOperations: MathOperationSettings) {
        guard let encoded = try? JSONEncoder().encode(mathOperations) else { return }
        defaults.set(encoded, forKey: Key.mathOperations)
    }

    func loadPracticeSettings() -> PracticeSettings? {
        guard let data = defaults.data(forKey: Key.practiceSettings) else { return nil }
        do {
            return try JSONDecoder().decode(PracticeSettings.self, from: data)
        } catch {
            AppLog.persistence.error("Failed to decode saved practice settings, resetting: \(error.localizedDescription)")
            return nil
        }
    }

    func save(practiceSettings: PracticeSettings) {
        guard let encoded = try? JSONEncoder().encode(practiceSettings) else { return }
        defaults.set(encoded, forKey: Key.practiceSettings)
    }

    func loadQuestionMode() -> QuestionMode? {
        guard let rawValue = defaults.string(forKey: Key.questionMode) else { return nil }
        return QuestionMode(rawValue: rawValue)
    }

    func save(questionMode: QuestionMode) {
        defaults.set(questionMode.rawValue, forKey: Key.questionMode)
    }

    func loadContinuousMode() -> Bool? {
        guard defaults.object(forKey: Key.continuousMode) != nil else { return nil }
        return defaults.bool(forKey: Key.continuousMode)
    }

    func save(continuousMode: Bool) {
        defaults.set(continuousMode, forKey: Key.continuousMode)
    }

    /// Returns nil if no duration has been saved yet, matching the "not yet configured" case.
    func loadTimerDuration() -> Int? {
        guard defaults.object(forKey: Key.timerDuration) != nil else { return nil }
        let saved = defaults.integer(forKey: Key.timerDuration)
        return saved > 0 ? saved : nil
    }

    func save(timerDuration: Int) {
        defaults.set(timerDuration, forKey: Key.timerDuration)
    }

    func loadSoundEnabled() -> Bool? {
        guard defaults.object(forKey: Key.soundEnabled) != nil else { return nil }
        return defaults.bool(forKey: Key.soundEnabled)
    }

    func save(soundEnabled: Bool) {
        defaults.set(soundEnabled, forKey: Key.soundEnabled)
    }

    func loadAppColorScheme() -> AppColorScheme? {
        guard let rawValue = defaults.string(forKey: Key.appColorScheme) else { return nil }
        return AppColorScheme(rawValue: rawValue)
    }

    func save(appColorScheme: AppColorScheme) {
        defaults.set(appColorScheme.rawValue, forKey: Key.appColorScheme)
    }
}
