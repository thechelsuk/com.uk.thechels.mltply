import Foundation
import SwiftUI

enum AchievementType: String, Codable {
    case streak
    case numberMastery
    case totalCorrect
    case largeNumbers
}

enum AchievementIcon: Equatable {
    case emoji(String)
    /// An SF Symbol for in-app grids, plus an emoji used wherever only text can be shown (chat).
    case symbol(String, emoji: String)

    var chatEmoji: String {
        switch self {
        case .emoji(let emoji): return emoji
        case .symbol(_, let emoji): return emoji
        }
    }
}

struct Achievement: Identifiable {
    let id: String
    let type: AchievementType
    let title: String
    /// What the player has to do, shown while the achievement is locked.
    let description: String
    /// Past-tense celebration shown once the achievement is earned.
    let unlockedMessage: String
    let icon: AchievementIcon
    let color: String // hex string
    let requirement: Int
    var isUnlocked: Bool
    var unlockedDate: Date?

    // For number mastery achievements
    var number: Int?
    var operation: MathOperation?

    var pastelColor: Color {
        Color(hex: color) ?? .gray
    }
}

/// The only achievement data that is persisted; everything else is rebuilt from code
/// so wording and icon changes reach existing installs.
struct AchievementProgress: Codable {
    let id: String
    var isUnlocked: Bool
    var unlockedDate: Date?
}

class AchievementsManager: ObservableObject {
    @Published var achievements: [Achievement] = []

    private let achievementsKey = "MltplyAchievements"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        achievements = Self.makeDefaultAchievements()
        applySavedProgress()
    }

    static func makeDefaultAchievements() -> [Achievement] {
        var defaultAchievements: [Achievement] = []

        // Streak achievements
        let streakMilestones = [
            (5, "On Fire", "🔥", "FFB3BA"),
            (10, "Hot Streak", "⚡️", "FFDFBA"),
            (20, "Unstoppable", "💫", "FFFFBA"),
            (50, "Legendary", "⭐️", "BAFFC9"),
            (100, "Math Master", "👑", "BAE1FF")
        ]

        for (count, title, emoji, color) in streakMilestones {
            defaultAchievements.append(Achievement(
                id: "streak_\(count)",
                type: .streak,
                title: title,
                description: "Get \(count) correct answers in a row",
                unlockedMessage: "Congratulations! You got \(count) correct answers in a row.",
                icon: .emoji(emoji),
                color: color,
                requirement: count,
                isUnlocked: false
            ))
        }

        // Total correct achievements
        let totalMilestones: [(Int, String, String, String, String)] = [
            (10, "Getting Started", "star.fill", "⭐️", "E0BBE4"),
            (25, "Quick Learner", "star.circle.fill", "🌟", "D4A5A5"),
            (50, "Dedicated", "rosette", "🏵️", "FFDFD3"),
            (100, "Committed", "medal.fill", "🏅", "C5E1A5"),
            (250, "Expert", "crown.fill", "👑", "FFE0B2"),
            (500, "Genius", "sparkles", "✨", "B2DFDB"),
            (1000, "Legend", "flame.fill", "🔥", "FFCCBC")
        ]

        for (count, title, symbol, emoji, color) in totalMilestones {
            defaultAchievements.append(Achievement(
                id: "total_\(count)",
                type: .totalCorrect,
                title: title,
                description: "Answer \(count) questions correctly",
                unlockedMessage: "Congratulations! You've answered \(count) questions correctly.",
                icon: .symbol(symbol, emoji: emoji),
                color: color,
                requirement: count,
                isUnlocked: false
            ))
        }

        // Number mastery achievements - one for each number (1-12) and operation
        let operations: [(MathOperation, String, String, String)] = [
            (.addition, "Addition", "plus.circle.fill", "➕"),
            (.subtraction, "Subtraction", "minus.circle.fill", "➖"),
            (.multiplication, "Multiplication", "multiply.circle.fill", "✖️"),
            (.division, "Division", "divide.circle.fill", "➗")
        ]

        let pastelColors = ["B5EAD7", "FFDAC1", "C7CEEA", "FFB7B2", "E2F0CB", "FDE2E4", "CAFFBF", "9BF6FF", "A0C4FF", "BDB2FF", "FFC6FF", "FDFFB6"]

        for number in 1...12 {
            for (operation, opName, symbol, emoji) in operations {
                let colorIndex = ((number - 1) * 4 + operations.firstIndex(where: { $0.0 == operation })!) % pastelColors.count
                defaultAchievements.append(Achievement(
                    id: "number_\(number)_\(operation.rawValue)",
                    type: .numberMastery,
                    title: "\(number) \(opName) Master",
                    description: "Complete all \(number) \(opName.lowercased()) problems",
                    unlockedMessage: "Congratulations! You've completed all \(number) \(opName.lowercased()) problems.",
                    icon: .symbol(symbol, emoji: emoji),
                    color: pastelColors[colorIndex],
                    requirement: 12,
                    isUnlocked: false,
                    number: number,
                    operation: operation
                ))
            }
        }

        // Square mastery achievements (by range)
        // Starter: 1-12, Explorer: 13-99, Champion: 100+
        let squareRangeAchievements: [(String, String, String, String, String, ClosedRange<Int>)] = [
            ("square_starter", "Square Starter", "Master all squares from 1² to 12²", "You've mastered all squares from 1² to 12².", "B5EAD7", 1...12),
            ("square_explorer", "Square Explorer", "Master squares from 13² to 99²", "You've mastered squares from 13² to 99².", "FFDAC1", 13...99)
        ]

        for (id, title, goal, achieved, color, range) in squareRangeAchievements {
            defaultAchievements.append(Achievement(
                id: id,
                type: .numberMastery,
                title: title,
                description: goal,
                unlockedMessage: "Congratulations! \(achieved)",
                icon: .symbol("square.fill", emoji: "🟦"),
                color: color,
                requirement: range.count,
                isUnlocked: false,
                number: range.lowerBound,  // Store lower bound to identify range
                operation: .square
            ))
        }

        // Square root mastery achievements (by range)
        // Roots where answer is 1-12, 13-99, etc.
        let sqrtRangeAchievements: [(String, String, String, String, String, ClosedRange<Int>)] = [
            ("sqrt_starter", "Root Starter", "Master all square roots √1 to √144", "You've mastered all square roots √1 to √144.", "C7CEEA", 1...12),
            ("sqrt_explorer", "Root Explorer", "Master square roots √169 to √9801", "You've mastered square roots √169 to √9801.", "FFB7B2", 13...99)
        ]

        for (id, title, goal, achieved, color, range) in sqrtRangeAchievements {
            defaultAchievements.append(Achievement(
                id: id,
                type: .numberMastery,
                title: title,
                description: goal,
                unlockedMessage: "Congratulations! \(achieved)",
                icon: .symbol("x.squareroot", emoji: "🌱"),
                color: color,
                requirement: range.count,
                isUnlocked: false,
                number: range.lowerBound,  // Store lower bound to identify range
                operation: .squareRoot
            ))
        }

        // Large number milestones
        let largeNumberMilestones: [(Int, Int, String, String, String, String)] = [
            (12, 10, "Explorer Initiate", "map.fill", "🗺️", "B5EAD7"),
            (12, 25, "Explorer Adept", "map.fill", "🗺️", "98D8C8"),
            (12, 50, "Explorer Expert", "map.fill", "🗺️", "7BC8B8"),
            (100, 10, "Champion Initiate", "trophy.fill", "🏆", "FFDAC1"),
            (100, 25, "Champion Adept", "trophy.fill", "🏆", "FFCBA4"),
            (100, 50, "Champion Expert", "trophy.fill", "🏆", "FFB987"),
            (1000, 10, "GOAT Initiate", "crown.fill", "👑", "C7CEEA"),
            (1000, 25, "GOAT Adept", "crown.fill", "👑", "B3BAE0"),
            (1000, 50, "GOAT Legend", "crown.fill", "👑", "9FA6D6")
        ]

        for (threshold, count, title, symbol, emoji, color) in largeNumberMilestones {
            defaultAchievements.append(Achievement(
                id: "large_\(threshold)_\(count)",
                type: .largeNumbers,
                title: title,
                description: "Answer \(count) questions with numbers over \(threshold)",
                unlockedMessage: "Congratulations! You've answered \(count) questions with numbers over \(threshold).",
                icon: .symbol(symbol, emoji: emoji),
                color: color,
                requirement: count,
                isUnlocked: false,
                number: threshold
            ))
        }

        return defaultAchievements
    }

    @discardableResult
    func checkAndUnlockAchievements(questionHistory: QuestionHistory) -> [Achievement] {
        var hasChanges = false
        var newlyUnlocked: [Achievement] = []

        for index in achievements.indices {
            guard !achievements[index].isUnlocked else { continue }

            var shouldUnlock = false

            switch achievements[index].type {
            case .streak:
                shouldUnlock = questionHistory.longestStreak >= achievements[index].requirement

            case .totalCorrect:
                shouldUnlock = questionHistory.totalCorrect >= achievements[index].requirement

            case .numberMastery:
                if let number = achievements[index].number,
                   let operation = achievements[index].operation {
                    if operation == .square {
                        // Check if all squares in range are completed
                        let range = getSquareRange(from: achievements[index].id)
                        shouldUnlock = questionHistory.hasCompletedAllSquaresInRange(range)
                    } else if operation == .squareRoot {
                        // Check if all square roots in range are completed
                        let range = getSquareRange(from: achievements[index].id)
                        shouldUnlock = questionHistory.hasCompletedAllSquareRootsInRange(range)
                    } else {
                        shouldUnlock = questionHistory.hasCompletedNumber(number, operation: operation)
                    }
                }

            case .largeNumbers:
                if let threshold = achievements[index].number {
                    let count = questionHistory.correctAnswersWithNumbersOver(threshold)
                    shouldUnlock = count >= achievements[index].requirement
                }
            }

            if shouldUnlock {
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = Date()
                newlyUnlocked.append(achievements[index])
                hasChanges = true
            }
        }

        if hasChanges {
            saveAchievements()
        }

        return newlyUnlocked
    }

    // Helper to determine the range for square/sqrt achievements based on ID
    private func getSquareRange(from id: String) -> ClosedRange<Int> {
        switch id {
        case "square_starter", "sqrt_starter":
            return 1...12
        case "square_explorer", "sqrt_explorer":
            return 13...99
        default:
            return 1...12
        }
    }

    func clearAllAchievements() {
        for index in achievements.indices {
            achievements[index].isUnlocked = false
            achievements[index].unlockedDate = nil
        }
        saveAchievements()
    }

    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }

    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }

    var streakAchievements: [Achievement] {
        achievements.filter { $0.type == .streak }
    }

    var totalAchievements: [Achievement] {
        achievements.filter { $0.type == .totalCorrect }
    }

    var masteryAchievements: [Achievement] {
        achievements.filter { $0.type == .numberMastery }
    }

    private func saveAchievements() {
        let progress = achievements
            .filter { $0.isUnlocked }
            .map { AchievementProgress(id: $0.id, isUnlocked: true, unlockedDate: $0.unlockedDate) }
        do {
            defaults.set(try JSONEncoder().encode(progress), forKey: achievementsKey)
        } catch {
            AppLog.persistence.error("Failed to encode achievement progress: \(error.localizedDescription)")
        }
    }

    private func applySavedProgress() {
        guard let data = defaults.data(forKey: achievementsKey) else { return }
        do {
            let saved = try JSONDecoder().decode([AchievementProgress].self, from: data)
            let byID = Dictionary(saved.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            for index in achievements.indices {
                guard let progress = byID[achievements[index].id], progress.isUnlocked else { continue }
                achievements[index].isUnlocked = true
                achievements[index].unlockedDate = progress.unlockedDate
            }
        } catch {
            AppLog.persistence.error("Failed to decode saved achievement progress, resetting: \(error.localizedDescription)")
        }
    }
}

// Helper extension for Color from hex string
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
