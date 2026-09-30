// BotMessages.swift
// Typed access to Buddy's wording. The text itself lives in Localizable.xcstrings.

import Foundation

enum BotMessages {
    static var welcome: String { String(localized: .botWelcome) }
    static var onboardingSettings: String { String(localized: .botOnboardingSettings) }
    static var onboardingReply: String { String(localized: .botOnboardingReply) }
    static var playAgain: String { String(localized: .botPlayAgain) }
    static var readyToBegin: String { String(localized: .botReadyToBegin) }
    static var letsGo: String { String(localized: .botLetsGo) }
    static var newRound: String { String(localized: .botNewRound) }
    static var playAgainReply: String { String(localized: .botPlayAgainReply) }
    static var encouragementFallback: String { String(localized: .botEncouragementFallback) }

    static func correctAnswer(_ answer: Int) -> String {
        String(localized: .botCorrectAnswer(answer))
    }

    static func scoreSummary(correct: Int, total: Int, incorrect: Int, allCorrect: Bool) -> String {
        let summary = String(localized: .botScoreSummary(correct, total, incorrect))
        return allCorrect ? summary + " 🏆" : summary
    }

    static func achievementUnlocked(_ achievement: Achievement) -> String {
        String(localized: .botAchievementAnnouncement(
            achievement.icon.chatEmoji, achievement.title, achievement.unlockedMessage))
    }

    static var encouragements: [String] {
        (1...8).map { String(localized: String.LocalizationValue("encouragement.\($0)")) }
    }

    static func question(_ operation: MathOperation, _ first: Int, _ second: Int) -> String {
        switch operation {
        case .addition: return String(localized: .questionAddition(first, second))
        case .subtraction: return String(localized: .questionSubtraction(first, second))
        case .multiplication: return String(localized: .questionMultiplication(first, second))
        case .division: return String(localized: .questionDivision(first, second))
        case .square: return String(localized: .questionSquare(first))
        case .squareRoot: return String(localized: .questionSquareRoot(first))
        }
    }
}
