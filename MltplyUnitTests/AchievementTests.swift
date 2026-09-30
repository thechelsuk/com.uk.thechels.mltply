import UIKit
import XCTest

@testable import Mltply

final class AchievementTests: XCTestCase {
    private let storageKey = "MltplyAchievements"
    private var suiteName = ""
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "AchievementTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    /// The shape the app persisted before definitions were rebuilt from code.
    private struct LegacyAchievement: Codable {
        let id: String
        let type: AchievementType
        let title: String
        let description: String
        let iconName: String
        let color: String
        let requirement: Int
        var isUnlocked: Bool
        var unlockedDate: Date?
    }

    private func seedLegacy(_ items: [LegacyAchievement]) {
        defaults.set(try! JSONEncoder().encode(items), forKey: storageKey)
    }

    private func legacy(id: String, title: String = "Old title", iconName: String = "rosette",
                        unlocked: Bool, date: Date? = nil) -> LegacyAchievement {
        LegacyAchievement(
            id: id, type: .totalCorrect, title: title, description: "Old description",
            iconName: iconName, color: "FFFFFF", requirement: 50, isUnlocked: unlocked, unlockedDate: date)
    }

    // MARK: - Definitions

    func testDefaultAchievementIDsAreUnique() {
        let ids = AchievementsManager.makeDefaultAchievements().map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count)
    }

    func testEveryAchievementHasAnEmojiForChat() {
        for achievement in AchievementsManager.makeDefaultAchievements() {
            let emoji = achievement.icon.chatEmoji
            XCTAssertFalse(emoji.isEmpty, "\(achievement.id) has no chat emoji")
            XCTAssertFalse(
                emoji.contains { $0.isASCII && ($0.isLetter || $0 == ".") },
                "\(achievement.id) chat icon looks like a symbol name: \(emoji)")
        }
    }

    func testRosetteAchievementUsesRosetteEmojiInChat() {
        let dedicated = AchievementsManager.makeDefaultAchievements().first { $0.id == "total_50" }
        XCTAssertEqual(dedicated?.icon.chatEmoji, "🏵️")
    }

    func testEveryAchievementSymbolExists() {
        for achievement in AchievementsManager.makeDefaultAchievements() {
            guard case .symbol(let name, _) = achievement.icon else { continue }
            XCTAssertNotNil(UIImage(systemName: name), "\(achievement.id) uses unknown SF Symbol \(name)")
        }
    }

    func testEachTierOfALargeNumberGroupHasItsOwnEmoji() {
        let all = AchievementsManager.makeDefaultAchievements()
        func emoji(_ id: String) -> String? { all.first { $0.id == id }?.icon.chatEmoji }

        XCTAssertEqual([emoji("large_12_10"), emoji("large_12_25"), emoji("large_12_50")], ["🧭", "⛰️", "🌍"])
        XCTAssertEqual([emoji("large_100_10"), emoji("large_100_25"), emoji("large_100_50")], ["🥉", "🥈", "🥇"])
        XCTAssertEqual([emoji("large_1000_10"), emoji("large_1000_25"), emoji("large_1000_50")], ["🐐", "🔥", "👑"])
    }

    func testUnlockedMessagesAreCongratulatoryAndPastTense() {
        for achievement in AchievementsManager.makeDefaultAchievements() {
            XCTAssertTrue(
                achievement.unlockedMessage.hasPrefix("Congratulations!"),
                "\(achievement.id): \(achievement.unlockedMessage)")
            XCTAssertNotEqual(achievement.unlockedMessage, achievement.description)
        }
    }

    func testTotalCorrectWording() {
        let dedicated = AchievementsManager.makeDefaultAchievements().first { $0.id == "total_50" }
        XCTAssertEqual(dedicated?.description, "Answer 50 questions correctly")
        XCTAssertEqual(dedicated?.unlockedMessage, "Congratulations! You've answered 50 questions correctly.")
    }

    func testStreakAndMasteryWording() {
        let all = AchievementsManager.makeDefaultAchievements()
        XCTAssertEqual(
            all.first { $0.id == "streak_5" }?.unlockedMessage,
            "Congratulations! You got 5 correct answers in a row.")
        XCTAssertEqual(
            all.first { $0.id == "number_7_addition" }?.unlockedMessage,
            "Congratulations! You've completed all 7 addition problems.")
        XCTAssertEqual(
            all.first { $0.id == "large_100_25" }?.unlockedMessage,
            "Congratulations! You've answered 25 questions with numbers over 100.")
    }

    // MARK: - Chat announcement

    func testChatAnnouncementFormat() {
        let dedicated = AchievementsManager.makeDefaultAchievements().first { $0.id == "total_50" }!
        XCTAssertEqual(
            BotMessages.achievementUnlocked(dedicated),
            "🏵️ Achievement unlocked: Dedicated\nCongratulations! You've answered 50 questions correctly.")
    }

    func testChatAnnouncementNeverContainsRawSymbolName() {
        for achievement in AchievementsManager.makeDefaultAchievements() {
            guard case .symbol(let name, _) = achievement.icon else { continue }
            XCTAssertFalse(
                BotMessages.achievementUnlocked(achievement).contains(name),
                "\(achievement.id) leaks symbol name \(name) into chat")
        }
    }

    // MARK: - Persistence

    func testStaleSavedDefinitionsAreRefreshedButProgressIsKept() {
        let unlockedAt = Date(timeIntervalSince1970: 1_700_000_000)
        seedLegacy([legacy(id: "total_50", unlocked: true, date: unlockedAt)])

        let manager = AchievementsManager(defaults: defaults)
        let dedicated = manager.achievements.first { $0.id == "total_50" }

        XCTAssertEqual(dedicated?.isUnlocked, true)
        XCTAssertEqual(dedicated?.unlockedDate?.timeIntervalSince1970 ?? 0, unlockedAt.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(dedicated?.title, "Dedicated")
        XCTAssertEqual(dedicated?.icon.chatEmoji, "🏵️")
    }

    func testAchievementsRemovedFromTheAppAreDropped() {
        seedLegacy([legacy(id: "retired_achievement", unlocked: true, date: Date())])
        let manager = AchievementsManager(defaults: defaults)
        XCTAssertFalse(manager.achievements.contains { $0.id == "retired_achievement" })
    }

    func testNewAchievementsAreAddedForExistingUsers() {
        seedLegacy([legacy(id: "streak_5", unlocked: true, date: Date())])
        let manager = AchievementsManager(defaults: defaults)
        XCTAssertEqual(manager.achievements.count, AchievementsManager.makeDefaultAchievements().count)
        XCTAssertEqual(manager.achievements.filter(\.isUnlocked).map(\.id), ["streak_5"])
    }

    func testCorruptSavedDataFallsBackToLockedDefaults() {
        defaults.set(Data("not json".utf8), forKey: storageKey)
        let manager = AchievementsManager(defaults: defaults)
        XCTAssertEqual(manager.achievements.count, AchievementsManager.makeDefaultAchievements().count)
        XCTAssertTrue(manager.achievements.allSatisfy { !$0.isUnlocked })
    }

    func testOnlyProgressIsPersisted() throws {
        let manager = AchievementsManager(defaults: defaults)
        let history = QuestionHistory()
        history.clearHistory()
        for i in 1...5 {
            history.addRecord(question: "q", firstNumber: i, secondNumber: 1, operation: .addition,
                              correctAnswer: i + 1, userAnswer: i + 1)
        }
        manager.checkAndUnlockAchievements(questionHistory: history)
        history.clearHistory()

        let data = try XCTUnwrap(defaults.data(forKey: storageKey))
        let stored = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [[String: Any]])
        let allowed: Set<String> = ["id", "isUnlocked", "unlockedDate"]
        XCTAssertFalse(stored.isEmpty)
        for entry in stored {
            XCTAssertTrue(Set(entry.keys).isSubset(of: allowed), "Unexpected persisted keys: \(entry.keys)")
        }
    }

    func testUnlockedProgressSurvivesReload() {
        let manager = AchievementsManager(defaults: defaults)
        let history = QuestionHistory()
        history.clearHistory()
        for i in 1...5 {
            history.addRecord(question: "q", firstNumber: i, secondNumber: 1, operation: .addition,
                              correctAnswer: i + 1, userAnswer: i + 1)
        }

        let unlocked = manager.checkAndUnlockAchievements(questionHistory: history)
        XCTAssertTrue(unlocked.contains { $0.id == "streak_5" })
        history.clearHistory()

        let reloaded = AchievementsManager(defaults: defaults)
        XCTAssertEqual(reloaded.achievements.first { $0.id == "streak_5" }?.isUnlocked, true)
    }

    func testClearAllAchievementsLocksEverythingAndPersists() {
        let manager = AchievementsManager(defaults: defaults)
        let history = QuestionHistory()
        history.clearHistory()
        for i in 1...5 {
            history.addRecord(question: "q", firstNumber: i, secondNumber: 1, operation: .addition,
                              correctAnswer: i + 1, userAnswer: i + 1)
        }
        manager.checkAndUnlockAchievements(questionHistory: history)
        history.clearHistory()

        manager.clearAllAchievements()

        XCTAssertTrue(AchievementsManager(defaults: defaults).achievements.allSatisfy { !$0.isUnlocked })
    }
}
