import XCTest

@testable import Mltply

final class LocalizationTests: XCTestCase {

    // MARK: - Bot copy

    func testBotCopy() {
        XCTAssertEqual(
            BotMessages.welcome,
            "Hi! I'm Buddy, your friendly robot. I love maths and I'm keen to learn about the numbers you have on planet Earth, so let's get ready to play! 🌍")
        XCTAssertEqual(BotMessages.onboardingReply, "Once ready, reply with any message to begin!")
        XCTAssertEqual(BotMessages.playAgain, "Would you like to play again?")
        XCTAssertEqual(BotMessages.readyToBegin, "Ready to begin?")
        XCTAssertEqual(BotMessages.letsGo, "OK, great, let's go!")
        XCTAssertEqual(BotMessages.newRound, "Starting a new round!")
        XCTAssertEqual(BotMessages.playAgainReply, "Yes, let's play again")
    }

    func testCorrectAnswerMessage() {
        XCTAssertEqual(BotMessages.correctAnswer(42), "The correct answer is 42")
    }

    func testScoreSummary() {
        XCTAssertEqual(
            BotMessages.scoreSummary(correct: 3, total: 5, incorrect: 2, allCorrect: false),
            "Time's up! You answered 3 out of 5 questions correctly.\nIncorrect answers: 2")
        XCTAssertEqual(
            BotMessages.scoreSummary(correct: 5, total: 5, incorrect: 0, allCorrect: true),
            "Time's up! You answered 5 out of 5 questions correctly.\nIncorrect answers: 0 🏆")
    }

    func testEncouragementMessages() {
        XCTAssertEqual(BotMessages.encouragements.count, 8)
        XCTAssertTrue(BotMessages.encouragements.allSatisfy { !$0.isEmpty })
        XCTAssertEqual(BotMessages.encouragementFallback, "Keep practicing!")
    }

    // MARK: - Question stems

    func testQuestionStems() {
        XCTAssertEqual(BotMessages.question(.addition, 5, 3), "What is 5 + 3?")
        XCTAssertEqual(BotMessages.question(.subtraction, 9, 4), "What is 9 - 4?")
        XCTAssertEqual(BotMessages.question(.multiplication, 6, 7), "What is 6 × 7?")
        XCTAssertEqual(BotMessages.question(.division, 12, 4), "What is 12 ÷ 4?")
        XCTAssertEqual(BotMessages.question(.square, 5, 5), "What is 5²?")
        XCTAssertEqual(BotMessages.question(.squareRoot, 25, 5), "What is √25?")
    }

    func testGeneratedQuestionsUseTheLocalizedStem() {
        let viewModel = QuizViewModel()
        viewModel.mathOperations = MathOperationSettings(
            additionEnabled: false, subtractionEnabled: false, multiplicationEnabled: true,
            divisionEnabled: false, squareEnabled: false, squareRootEnabled: false)
        viewModel.practiceSettings.difficulty = .starter
        viewModel.practiceSettings.selectedNumbers = Set(1...12)

        let question = viewModel.generateMathQuestion()
        XCTAssertEqual(
            question.question,
            BotMessages.question(.multiplication, question.firstNumber, question.secondNumber))
    }

    @MainActor
    func testQuestionsAreFlaggedSoStylingDoesNotDependOnWording() {
        let viewModel = QuizViewModel()
        viewModel.messageDelayScale = 0.01
        viewModel.startQuiz()

        let arrived = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in viewModel.messages.contains { $0.isQuestion } },
            object: nil)
        wait(for: [arrived], timeout: 5)

        let flagged = viewModel.messages.filter(\.isQuestion)
        XCTAssertEqual(flagged.count, 1)
        XCTAssertEqual(flagged.first?.text, viewModel.currentQuestion?.question)
        XCTAssertFalse(viewModel.messages.contains { !$0.isQuestion && $0.text == flagged.first?.text })
    }

    // MARK: - Display names

    func testOperationsSummary() {
        func summary(add: Bool = false, sub: Bool = false, mul: Bool = false, div: Bool = false,
                     sq: Bool = false, root: Bool = false) -> String {
            MathOperationSettings(
                additionEnabled: add, subtractionEnabled: sub, multiplicationEnabled: mul,
                divisionEnabled: div, squareEnabled: sq, squareRootEnabled: root
            ).summary
        }
        XCTAssertEqual(summary(), "None")
        XCTAssertEqual(summary(add: true), "Addition")
        XCTAssertEqual(summary(add: true, sub: true), "Addition and Subtraction")
        XCTAssertEqual(summary(add: true, sub: true, mul: true), "Addition, Subtraction and Multiplication")
        XCTAssertEqual(summary(sq: true, root: true), "Squares and √ Roots")
        XCTAssertEqual(summary(add: true, sub: true, mul: true, div: true, sq: true, root: true), "All operations")
    }

    func testNumberDifficultyNames() {
        XCTAssertEqual(NumberDifficulty.starter.displayName, "Starter")
        XCTAssertEqual(NumberDifficulty.goat.displayName, "GOAT")
        XCTAssertEqual(NumberDifficulty.explorer.rangeDescription, "Numbers 1-100 • Random")
    }

    // MARK: - Catalog integrity

    private struct Catalog: Decodable {
        struct Entry: Decodable {
            struct Localization: Decodable {
                struct Unit: Decodable { let state: String?; let value: String }
                let stringUnit: Unit?
            }
            let localizations: [String: Localization]?
        }
        let sourceLanguage: String
        let strings: [String: Entry]
    }

    private func loadCatalog() throws -> Catalog {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        let url = root.appendingPathComponent("Mltply/Localizable.xcstrings")
        return try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: url))
    }

    func testCatalogIsEnglishSourceAndEveryEntryIsTranslated() throws {
        let catalog = try loadCatalog()
        XCTAssertEqual(catalog.sourceLanguage, "en")
        XCTAssertGreaterThan(catalog.strings.count, 100)
        for (key, entry) in catalog.strings {
            let unit = entry.localizations?["en"]?.stringUnit
            XCTAssertEqual(unit?.state, "translated", "\(key) is not marked translated")
            XCTAssertFalse(unit?.value.isEmpty ?? true, "\(key) has no English value")
        }
    }

    func testEveryAchievementResolvesItsTextFromTheCatalog() {
        // A missing key makes String(localized:) return the key itself.
        for achievement in AchievementsManager.makeDefaultAchievements() {
            for text in [achievement.title, achievement.description, achievement.unlockedMessage] {
                XCTAssertFalse(text.hasPrefix("achievement."), "\(achievement.id) is missing catalog text: \(text)")
                XCTAssertFalse(text.isEmpty)
            }
        }
    }
}
