import Foundation

struct Score: Codable, Identifiable {
    let id: UUID
    let value: Int
    let date: Date
    
    init(id: UUID = UUID(), value: Int, date: Date) {
        self.id = id
        self.value = value
        self.date = date
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class ScoreManager: ObservableObject {
    @Published var currentScore: Int = 0
    @Published var allScores: [Score] = []
    
    private let scoresKey = "MltplyScores"
    
    init() {
        loadScores()
    }
    
    func addCorrectAnswer() {
        currentScore += 1
    }
    
    func saveCurrentScore() {
        guard currentScore > 0 else { return }
        
        let newScore = Score(value: currentScore, date: Date())
        allScores.append(newScore)
        allScores.sort { $0.value > $1.value } // Sort by highest score first
        
        saveScores()
        currentScore = 0
    }
    
    func clearAllScores() {
        allScores.removeAll()
        currentScore = 0
        saveScores()
    }
    
    var topScores: [Score] {
        Array(allScores.prefix(10)) // Show top 10 scores
    }
    
    var personalBest: Int {
        allScores.first?.value ?? 0
    }
    
    private func saveScores() {
        if let encoded = try? JSONEncoder().encode(allScores) {
            UserDefaults.standard.set(encoded, forKey: scoresKey)
        }
    }
    
    private func loadScores() {
        guard let data = UserDefaults.standard.data(forKey: scoresKey) else { return }
        do {
            allScores = try JSONDecoder().decode([Score].self, from: data).sorted { $0.value > $1.value }
        } catch {
            AppLog.persistence.error("Failed to decode saved scores, resetting: \(error.localizedDescription)")
        }
    }
}
