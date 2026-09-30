import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var isTypingIndicator: Bool = false
    var tapback: Tapback? = nil
    var accessibilityIdentifier: String? = nil
    /// True for Buddy's maths questions, so styling never depends on the wording.
    var isQuestion: Bool = false
}

enum Tapback: String {
    case correct, incorrect
}

enum MathOperation: String, Codable {
    case addition = "addition"
    case subtraction = "subtraction"
    case multiplication = "multiplication"
    case division = "division"
    case square = "square"
    case squareRoot = "squareRoot"
}

struct MathQuestion {
    let question: String
    let answer: Int
    let firstNumber: Int
    let secondNumber: Int
    let operation: MathOperation
}

struct MathOperationSettings: Equatable, Codable {
    var additionEnabled: Bool = true
    var subtractionEnabled: Bool = true
    var multiplicationEnabled: Bool = true
    var divisionEnabled: Bool = true
    var squareEnabled: Bool = false
    var squareRootEnabled: Bool = false

    var hasAtLeastOneEnabled: Bool {
        return additionEnabled || subtractionEnabled || multiplicationEnabled || divisionEnabled || squareEnabled || squareRootEnabled
    }

    /// Human-readable list of the enabled operations, e.g. "Addition and Subtraction".
    var summary: String {
        var names: [String] = []
        if additionEnabled { names.append(String(localized: .operationAddition)) }
        if subtractionEnabled { names.append(String(localized: .operationSubtraction)) }
        if multiplicationEnabled { names.append(String(localized: .operationMultiplication)) }
        if divisionEnabled { names.append(String(localized: .operationDivision)) }
        if squareEnabled { names.append(String(localized: .operationSquare)) }
        if squareRootEnabled { names.append(String(localized: .operationSquareRoot)) }

        switch names.count {
        case 0: return String(localized: .operationsNone)
        case 1: return names[0]
        case 6: return String(localized: .operationsAll)
        default:
            let allButLast = names.dropLast().joined(separator: ", ")
            return String(localized: .operationsAnd(allButLast, names.last!))
        }
    }
}

public enum QuestionMode: String, CaseIterable, Identifiable, Codable {
    case random = "random"
    case sequential = "Ascending"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .random: return String(localized: .questionModeRandom)
        case .sequential: return String(localized: .questionModeAscending)
        }
    }

    public var iconName: String {
        switch self {
        case .random: return "shuffle"
        case .sequential: return "arrow.up.arrow.down"
        }
    }
}

public enum NumberDifficulty: String, CaseIterable, Identifiable, Codable {
    case starter = "starter"
    case explorer = "explorer"
    case champion = "champion"
    case goat = "goat"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .starter: return String(localized: .difficultyStarter)
        case .explorer: return String(localized: .difficultyExplorer)
        case .champion: return String(localized: .difficultyChampion)
        case .goat: return String(localized: .difficultyGoat)
        }
    }

    public var range: ClosedRange<Int> {
        switch self {
        case .starter: return 1...12
        case .explorer: return 1...100
        case .champion: return 1...1000
        case .goat: return 1...9999
        }
    }

    public var iconName: String {
        switch self {
        case .starter: return "leaf"
        case .explorer: return "map"
        case .champion: return "trophy"
        case .goat: return "crown"
        }
    }

    /// Whether this difficulty allows granular number selection
    public var allowsGranularSelection: Bool {
        self == .starter
    }

    /// Description of the number range for UI display
    public var rangeDescription: String {
        switch self {
        case .starter: return String(localized: .difficultyStarterRange)
        case .explorer: return String(localized: .difficultyExplorerRange)
        case .champion: return String(localized: .difficultyChampionRange)
        case .goat: return String(localized: .difficultyGoatRange)
        }
    }
}

struct PracticeSettings: Equatable, Codable {
    var selectedNumbers: Set<Int> = Set(1...12)  // All numbers 1-12 selected by default (used for Starter mode)
    var currentNumberIndex: Int = 0
    var currentMultiplier: Int = 1
    var difficulty: NumberDifficulty = .starter

    private var sortedNumbers: [Int] {
        selectedNumbers.sorted()
    }

    var currentNumber: Int {
        guard !sortedNumbers.isEmpty else { return 1 }
        return sortedNumbers[currentNumberIndex % sortedNumbers.count]
    }

    var hasSelectedNumbers: Bool {
        // For non-starter modes, we always have numbers available via random generation
        if !difficulty.allowsGranularSelection {
            return true
        }
        return !selectedNumbers.isEmpty
    }

    /// Get the maximum multiplier based on difficulty
    var maxMultiplier: Int {
        difficulty.range.upperBound
    }

    mutating func nextQuestion() {
        let maxMult = difficulty.allowsGranularSelection ? 12 : maxMultiplier
        if currentMultiplier < maxMult {
            currentMultiplier += 1
        } else {
            // Move to next number
            currentMultiplier = 1
            if difficulty.allowsGranularSelection && !sortedNumbers.isEmpty {
                currentNumberIndex = (currentNumberIndex + 1) % sortedNumbers.count
            }
        }
    }

    mutating func reset() {
        currentMultiplier = 1
        currentNumberIndex = 0
    }

    mutating func toggleNumber(_ number: Int) {
        if selectedNumbers.contains(number) {
            selectedNumbers.remove(number)
        } else {
            selectedNumbers.insert(number)
        }
        // Reset to first number when selection changes
        reset()
    }
}

enum AppColorScheme: String, CaseIterable, Identifiable {
    case light, dark, system
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .system: return String(localized: .colorSchemeSystem)
        case .light: return String(localized: .colorSchemeLight)
        case .dark: return String(localized: .colorSchemeDark)
        }
    }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    var iconName: String {
        switch self {
        case .system: return "gear"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

