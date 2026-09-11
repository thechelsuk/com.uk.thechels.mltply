import Foundation

struct QuestionRecord: Codable, Identifiable {
    let id: UUID
    let question: String
    let firstNumber: Int
    let secondNumber: Int
    let operation: MathOperation
    let correctAnswer: Int
    let userAnswer: Int
    let isCorrect: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), question: String, firstNumber: Int, secondNumber: Int, operation: MathOperation, correctAnswer: Int, userAnswer: Int, timestamp: Date = Date()) {
        self.id = id
        self.question = question
        self.firstNumber = firstNumber
        self.secondNumber = secondNumber
        self.operation = operation
        self.correctAnswer = correctAnswer
        self.userAnswer = userAnswer
        self.isCorrect = correctAnswer == userAnswer
        self.timestamp = timestamp
    }
}

class QuestionHistory: ObservableObject {
    @Published var records: [QuestionRecord] = []

    private let historyKey = "MltplyQuestionHistory"

    // Derived state kept incrementally as records are added, rather than rescanned
    // from the full `records` array on every read. Achievement checks call several
    // of the computed properties/methods below after *every* answered question, so
    // an O(n) rescan would make each answer progressively slower as history grows
    // over the app's lifetime (see AchievementsManager.checkAndUnlockAchievements).
    private var currentStreakCount = 0
    private var longestStreakCount = 0
    private var totalCorrectCount = 0
    // [operation: [number: set of the "other" operand seen paired with it in a correct answer]]
    private var completedPairsByOperation: [MathOperation: [Int: Set<Int>]] = [:]
    private var completedSquareBases: Set<Int> = []
    private var completedSquareRoots: Set<Int> = []
    // Achievements only ever query a fixed set of "large number" thresholds
    // (see AchievementsManager's largeNumberMilestones); track those incrementally
    // and fall back to a scan for anything else.
    private var largeNumberCounts: [Int: Int] = [12: 0, 100: 0, 1000: 0]

    init() {
        loadHistory()
        rebuildDerivedState()
    }

    func addRecord(question: String, firstNumber: Int, secondNumber: Int, operation: MathOperation, correctAnswer: Int, userAnswer: Int) {
        let record = QuestionRecord(
            question: question,
            firstNumber: firstNumber,
            secondNumber: secondNumber,
            operation: operation,
            correctAnswer: correctAnswer,
            userAnswer: userAnswer
        )
        records.append(record)
        apply(record)
        saveHistory()
    }

    func clearHistory() {
        records.removeAll()
        resetDerivedState()
        saveHistory()
    }

    // Get current streak (consecutive correct from most recent)
    var currentStreak: Int { currentStreakCount }

    // Get longest ever streak
    var longestStreak: Int { longestStreakCount }

    // Total correct answers
    var totalCorrect: Int { totalCorrectCount }

    // Check if user has completed all questions for a specific number and operation
    func hasCompletedNumber(_ number: Int, operation: MathOperation) -> Bool {
        let requiredQuestions = Set(1...12)
        let answeredQuestions = completedPairsByOperation[operation]?[number] ?? []
        return answeredQuestions.isSuperset(of: requiredQuestions)
    }

    // Check if user has correctly answered a specific square or square root question
    func hasAnsweredCorrectly(number: Int, operation: MathOperation) -> Bool {
        records.contains { record in
            record.isCorrect &&
            record.operation == operation &&
            record.firstNumber == number
        }
    }

    // Check if all squares in a given base range have been answered correctly
    // e.g., range 1...12 means 1², 2², 3², ... 12²
    func hasCompletedAllSquaresInRange(_ range: ClosedRange<Int>) -> Bool {
        completedSquareBases.isSuperset(of: Set(range))
    }

    // Check if all square roots in a given answer range have been answered correctly
    // e.g., range 1...12 means √1, √4, √9, ... √144 (answers 1-12)
    func hasCompletedAllSquareRootsInRange(_ range: ClosedRange<Int>) -> Bool {
        completedSquareRoots.isSuperset(of: Set(range))
    }

    // Count correct answers where any number in the question exceeds the threshold
    func correctAnswersWithNumbersOver(_ threshold: Int) -> Int {
        if let cached = largeNumberCounts[threshold] { return cached }
        return records.filter { record in
            record.isCorrect &&
            (record.firstNumber > threshold || record.secondNumber > threshold)
        }.count
    }

    private func apply(_ record: QuestionRecord) {
        guard record.isCorrect else {
            currentStreakCount = 0
            return
        }

        currentStreakCount += 1
        longestStreakCount = max(longestStreakCount, currentStreakCount)
        totalCorrectCount += 1

        completedPairsByOperation[record.operation, default: [:]][record.firstNumber, default: []]
            .insert(record.secondNumber)
        completedPairsByOperation[record.operation, default: [:]][record.secondNumber, default: []]
            .insert(record.firstNumber)

        if record.operation == .square {
            completedSquareBases.insert(record.secondNumber)
        } else if record.operation == .squareRoot {
            completedSquareRoots.insert(record.secondNumber)
        }

        let maxOperand = max(record.firstNumber, record.secondNumber)
        for threshold in Array(largeNumberCounts.keys) where maxOperand > threshold {
            largeNumberCounts[threshold, default: 0] += 1
        }
    }

    private func rebuildDerivedState() {
        resetDerivedState()
        for record in records {
            apply(record)
        }
    }

    private func resetDerivedState() {
        currentStreakCount = 0
        longestStreakCount = 0
        totalCorrectCount = 0
        completedPairsByOperation = [:]
        completedSquareBases = []
        completedSquareRoots = []
        largeNumberCounts = [12: 0, 100: 0, 1000: 0]
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
        do {
            records = try JSONDecoder().decode([QuestionRecord].self, from: data)
        } catch {
            AppLog.persistence.error("Failed to decode saved question history, resetting: \(error.localizedDescription)")
        }
    }
}
