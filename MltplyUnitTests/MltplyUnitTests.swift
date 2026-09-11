import Foundation
import XCTest

@testable import Mltply

final class MltplyUnitTests: XCTestCase {

    // MARK: - MathOperationSettings Tests

    func testMathOperationSettingsInitialization() {
        let settings = MathOperationSettings()
        XCTAssertTrue(settings.additionEnabled)
        XCTAssertTrue(settings.subtractionEnabled)
        XCTAssertTrue(settings.multiplicationEnabled)
        XCTAssertTrue(settings.divisionEnabled)
        XCTAssertFalse(settings.squareEnabled)
        XCTAssertFalse(settings.squareRootEnabled)
        XCTAssertTrue(settings.hasAtLeastOneEnabled)
    }

    func testMathOperationSettingsHasAtLeastOneEnabled() {
        var settings = MathOperationSettings(
            additionEnabled: false,
            subtractionEnabled: false,
            multiplicationEnabled: false,
            divisionEnabled: false,
            squareEnabled: false,
            squareRootEnabled: false
        )
        XCTAssertFalse(settings.hasAtLeastOneEnabled)

        settings.additionEnabled = true
        XCTAssertTrue(settings.hasAtLeastOneEnabled)

        settings.additionEnabled = false
        settings.multiplicationEnabled = true
        XCTAssertTrue(settings.hasAtLeastOneEnabled)
        
        settings.multiplicationEnabled = false
        settings.squareEnabled = true
        XCTAssertTrue(settings.hasAtLeastOneEnabled)
        
        settings.squareEnabled = false
        settings.squareRootEnabled = true
        XCTAssertTrue(settings.hasAtLeastOneEnabled)
    }

    // MARK: - AppColorScheme Tests

    func testAppColorSchemeDisplayNames() {
        XCTAssertEqual(AppColorScheme.system.displayName, "System")
        XCTAssertEqual(AppColorScheme.light.displayName, "Light")
        XCTAssertEqual(AppColorScheme.dark.displayName, "Dark")
    }

    func testAppColorSchemeColorScheme() {
        XCTAssertNil(AppColorScheme.system.colorScheme)
        XCTAssertEqual(AppColorScheme.light.colorScheme, .light)
        XCTAssertEqual(AppColorScheme.dark.colorScheme, .dark)
    }

    // MARK: - QuestionMode Tests

    func testQuestionModeDisplayNames() {
        XCTAssertEqual(QuestionMode.random.displayName, "Random")
        XCTAssertEqual(QuestionMode.sequential.displayName, "Ascending")
    }

    func testQuestionModeIconNames() {
        XCTAssertEqual(QuestionMode.random.iconName, "shuffle")
        XCTAssertEqual(QuestionMode.sequential.iconName, "arrow.up.arrow.down")
    }

    // MARK: - NumberDifficulty Tests

    func testNumberDifficultyRanges() {
        XCTAssertEqual(NumberDifficulty.starter.range, 1...12)
        XCTAssertEqual(NumberDifficulty.explorer.range, 1...100)
        XCTAssertEqual(NumberDifficulty.champion.range, 1...1000)
        XCTAssertEqual(NumberDifficulty.goat.range, 1...9999)

        XCTAssertTrue(NumberDifficulty.starter.allowsGranularSelection)
        XCTAssertFalse(NumberDifficulty.explorer.allowsGranularSelection)
        XCTAssertFalse(NumberDifficulty.champion.allowsGranularSelection)
        XCTAssertFalse(NumberDifficulty.goat.allowsGranularSelection)
    }

    // MARK: - PracticeSettings Tests

    func testPracticeSettingsInitialization() {
        let settings = PracticeSettings()
        XCTAssertEqual(settings.selectedNumbers, Set(1...12))
        XCTAssertEqual(settings.currentNumberIndex, 0)
        XCTAssertEqual(settings.currentMultiplier, 1)
        XCTAssertEqual(settings.currentNumber, 1)
        XCTAssertTrue(settings.hasSelectedNumbers)
    }

    func testPracticeSettingsNextQuestion() {
        var settings = PracticeSettings()
        settings.selectedNumbers = Set([2, 5]) // Only 2 and 5

        // Start with 2 × 1
        XCTAssertEqual(settings.currentNumber, 2)
        XCTAssertEqual(settings.currentMultiplier, 1)

        // Should progress through multipliers first
        settings.nextQuestion()
        XCTAssertEqual(settings.currentNumber, 2)
        XCTAssertEqual(settings.currentMultiplier, 2)

        // Jump to 2 × 12
        for _ in 3...12 {
            settings.nextQuestion()
        }
        XCTAssertEqual(settings.currentNumber, 2)
        XCTAssertEqual(settings.currentMultiplier, 12)

        // Should move to next number and reset multiplier
        settings.nextQuestion()
        XCTAssertEqual(settings.currentNumber, 5)
        XCTAssertEqual(settings.currentMultiplier, 1)

        // Should cycle back to first number
        for _ in 2...12 {
            settings.nextQuestion()
        }
        settings.nextQuestion()
        XCTAssertEqual(settings.currentNumber, 2)
        XCTAssertEqual(settings.currentMultiplier, 1)
    }

    func testPracticeSettingsToggleNumber() {
        var settings = PracticeSettings()

        // Remove a number
        settings.toggleNumber(5)
        XCTAssertFalse(settings.selectedNumbers.contains(5))
        XCTAssertEqual(settings.currentMultiplier, 1) // Should reset
        XCTAssertEqual(settings.currentNumberIndex, 0)

        // Add it back
        settings.toggleNumber(5)
        XCTAssertTrue(settings.selectedNumbers.contains(5))

        // Remove all numbers
        for i in 1...12 {
            settings.toggleNumber(i)
        }
        XCTAssertTrue(settings.selectedNumbers.isEmpty)
        XCTAssertFalse(settings.hasSelectedNumbers)
    }

    func testPracticeSettingsEdgeCaseEmptySelection() {
        var settings = PracticeSettings()
        settings.selectedNumbers = Set<Int>()

        // Should return 1 as fallback when no numbers selected
        XCTAssertEqual(settings.currentNumber, 1)
        XCTAssertFalse(settings.hasSelectedNumbers)
    }

    // MARK: - ScoreManager Tests

    func testScoreManagerAddCorrectAnswerIncrementsCurrentScore() {
        let scoreManager = ScoreManager()
        scoreManager.clearAllScores()

        XCTAssertEqual(scoreManager.currentScore, 0)
        scoreManager.addCorrectAnswer()
        scoreManager.addCorrectAnswer()
        XCTAssertEqual(scoreManager.currentScore, 2)

        scoreManager.clearAllScores()
    }

    func testScoreManagerSaveCurrentScoreTracksPersonalBestAndTopScores() {
        let scoreManager = ScoreManager()
        scoreManager.clearAllScores()

        for _ in 0..<3 { scoreManager.addCorrectAnswer() }
        scoreManager.saveCurrentScore()
        XCTAssertEqual(scoreManager.currentScore, 0, "saveCurrentScore should reset the running score")
        XCTAssertEqual(scoreManager.personalBest, 3)

        for _ in 0..<7 { scoreManager.addCorrectAnswer() }
        scoreManager.saveCurrentScore()

        XCTAssertEqual(scoreManager.personalBest, 7)
        XCTAssertEqual(scoreManager.topScores.map(\.value), [7, 3], "topScores should be sorted highest first")

        scoreManager.clearAllScores()
        XCTAssertTrue(scoreManager.allScores.isEmpty)
        XCTAssertEqual(scoreManager.personalBest, 0)
    }

    func testScoreManagerDoesNotSaveZeroScore() {
        let scoreManager = ScoreManager()
        scoreManager.clearAllScores()

        scoreManager.saveCurrentScore() // currentScore is 0; should be a no-op
        XCTAssertTrue(scoreManager.allScores.isEmpty)
    }

    // MARK: - QuestionHistory Tests

    func testQuestionHistoryTracksStreaksAndTotals() {
        let history = QuestionHistory()
        history.clearHistory()

        history.addRecord(question: "What is 2 + 2?", firstNumber: 2, secondNumber: 2, operation: .addition, correctAnswer: 4, userAnswer: 4)
        history.addRecord(question: "What is 3 + 3?", firstNumber: 3, secondNumber: 3, operation: .addition, correctAnswer: 6, userAnswer: 6)
        XCTAssertEqual(history.currentStreak, 2)
        XCTAssertEqual(history.longestStreak, 2)
        XCTAssertEqual(history.totalCorrect, 2)

        history.addRecord(question: "What is 4 + 4?", firstNumber: 4, secondNumber: 4, operation: .addition, correctAnswer: 8, userAnswer: 99)
        XCTAssertEqual(history.currentStreak, 0, "An incorrect answer should reset the current streak")
        XCTAssertEqual(history.longestStreak, 2, "The longest streak is unaffected by a later miss")
        XCTAssertEqual(history.totalCorrect, 2)

        history.clearHistory()
        XCTAssertTrue(history.records.isEmpty)
    }

    func testQuestionHistoryCompletesNumberAcrossAllMultipliers() {
        let history = QuestionHistory()
        history.clearHistory()

        for multiplier in 1...12 {
            history.addRecord(
                question: "What is 5 x \(multiplier)?",
                firstNumber: 5, secondNumber: multiplier,
                operation: .multiplication,
                correctAnswer: 5 * multiplier, userAnswer: 5 * multiplier
            )
        }
        XCTAssertTrue(history.hasCompletedNumber(5, operation: .multiplication))
        XCTAssertFalse(history.hasCompletedNumber(6, operation: .multiplication))

        history.clearHistory()
    }

    func testQuestionHistoryCorrectAnswersWithNumbersOverThreshold() {
        let history = QuestionHistory()
        history.clearHistory()

        history.addRecord(question: "What is 5 + 5?", firstNumber: 5, secondNumber: 5, operation: .addition, correctAnswer: 10, userAnswer: 10)
        history.addRecord(question: "What is 50 + 5?", firstNumber: 50, secondNumber: 5, operation: .addition, correctAnswer: 55, userAnswer: 55)
        // Incorrect answer with a large number shouldn't count.
        history.addRecord(question: "What is 500 + 5?", firstNumber: 500, secondNumber: 5, operation: .addition, correctAnswer: 505, userAnswer: 0)

        XCTAssertEqual(history.correctAnswersWithNumbersOver(12), 1)

        history.clearHistory()
    }

    // MARK: - AchievementsManager Tests

    func testAchievementsManagerPreservesUnlockedStateAndAddsNewAchievementsOnMerge() {
        let key = "MltplyAchievements"
        let defaults = UserDefaults.standard
        let originalData = defaults.data(forKey: key)
        defer {
            if let originalData {
                defaults.set(originalData, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }

        // Simulate an old saved state, predating an achievement the current build ships with.
        let staleAchievement = Achievement(
            id: "streak_5",
            type: .streak,
            title: "On Fire",
            description: "Get 5 correct answers in a row",
            iconName: "🔥",
            color: "FFB3BA",
            requirement: 5,
            isUnlocked: true,
            unlockedDate: Date()
        )
        let encoded = try! JSONEncoder().encode([staleAchievement])
        defaults.set(encoded, forKey: key)

        let manager = AchievementsManager()

        // Previously unlocked achievements must survive the merge.
        XCTAssertEqual(manager.achievements.first(where: { $0.id == "streak_5" })?.isUnlocked, true)
        // Achievements only known to the current build must be merged in, not dropped.
        XCTAssertTrue(manager.achievements.contains(where: { $0.id == "large_1000_50" }))
        XCTAssertGreaterThan(manager.achievements.count, 1)
    }

    func testAchievementsManagerUnlocksStreakAchievement() {
        let key = "MltplyAchievements"
        let defaults = UserDefaults.standard
        let originalData = defaults.data(forKey: key)
        defer {
            if let originalData {
                defaults.set(originalData, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
        defaults.removeObject(forKey: key)

        let manager = AchievementsManager()
        let history = QuestionHistory()
        history.clearHistory()

        for i in 1...5 {
            history.addRecord(question: "What is \(i) + 1?", firstNumber: i, secondNumber: 1, operation: .addition, correctAnswer: i + 1, userAnswer: i + 1)
        }

        let unlocked = manager.checkAndUnlockAchievements(questionHistory: history)
        XCTAssertTrue(unlocked.contains(where: { $0.id == "streak_5" }))
        XCTAssertTrue(manager.achievements.first(where: { $0.id == "streak_5" })?.isUnlocked ?? false)

        history.clearHistory()
    }

    // MARK: - QuizSettingsStore Tests

    func testQuizSettingsStoreRoundTripsAllSettings() {
        let suiteName = "MltplyQuizSettingsStoreTests"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = QuizSettingsStore(defaults: defaults)

        XCTAssertNil(store.loadMathOperations())
        XCTAssertNil(store.loadPracticeSettings())
        XCTAssertNil(store.loadQuestionMode())
        XCTAssertNil(store.loadContinuousMode())
        XCTAssertNil(store.loadTimerDuration())
        XCTAssertNil(store.loadSoundEnabled())
        XCTAssertNil(store.loadAppColorScheme())
        XCTAssertNil(store.loadSelectedAppIcon())

        var mathOperations = MathOperationSettings()
        mathOperations.squareEnabled = true
        store.save(mathOperations: mathOperations)
        XCTAssertEqual(store.loadMathOperations(), mathOperations)

        var practiceSettings = PracticeSettings()
        practiceSettings.difficulty = .champion
        store.save(practiceSettings: practiceSettings)
        XCTAssertEqual(store.loadPracticeSettings(), practiceSettings)

        store.save(questionMode: .sequential)
        XCTAssertEqual(store.loadQuestionMode(), .sequential)

        store.save(continuousMode: false)
        XCTAssertEqual(store.loadContinuousMode(), false)

        store.save(timerDuration: 5)
        XCTAssertEqual(store.loadTimerDuration(), 5)

        store.save(soundEnabled: true)
        XCTAssertEqual(store.loadSoundEnabled(), true)

        store.save(appColorScheme: .dark)
        XCTAssertEqual(store.loadAppColorScheme(), .dark)

        store.save(selectedAppIcon: .glass)
        XCTAssertEqual(store.loadSelectedAppIcon(), .glass)
    }

    // MARK: - QuizViewModel Tests

    func testTimeStringFormatting() {
        let viewModel = QuizViewModel()
        viewModel.timeRemaining = 125
        XCTAssertEqual(viewModel.timeString, "02:05")
        viewModel.timeRemaining = 5
        XCTAssertEqual(viewModel.timeString, "00:05")
    }

    func testGenerateMathQuestionRespectsEnabledOperationsAndProducesCorrectAnswer() {
        let viewModel = QuizViewModel()
        viewModel.mathOperations = MathOperationSettings(
            additionEnabled: false,
            subtractionEnabled: false,
            multiplicationEnabled: true,
            divisionEnabled: false,
            squareEnabled: false,
            squareRootEnabled: false
        )
        viewModel.practiceSettings.difficulty = .starter
        viewModel.practiceSettings.selectedNumbers = Set(1...12)

        for _ in 0..<25 {
            let question = viewModel.generateMathQuestion()
            XCTAssertEqual(question.operation, .multiplication)
            XCTAssertEqual(question.firstNumber * question.secondNumber, question.answer)
        }
    }

    func testGenerateMathQuestionDivisionHasNoRemainder() {
        let viewModel = QuizViewModel()
        viewModel.mathOperations = MathOperationSettings(
            additionEnabled: false,
            subtractionEnabled: false,
            multiplicationEnabled: false,
            divisionEnabled: true,
            squareEnabled: false,
            squareRootEnabled: false
        )
        viewModel.practiceSettings.difficulty = .starter
        viewModel.practiceSettings.selectedNumbers = Set(1...12)

        for _ in 0..<25 {
            let question = viewModel.generateMathQuestion()
            XCTAssertEqual(question.operation, .division)
            XCTAssertEqual(question.firstNumber % question.secondNumber, 0)
            XCTAssertEqual(question.firstNumber / question.secondNumber, question.answer)
        }
    }
}
