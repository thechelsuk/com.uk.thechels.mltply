import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var scoreManager: ScoreManager
    @ObservedObject var achievementsManager: AchievementsManager
    @ObservedObject var questionHistory: QuestionHistory
    @Environment(\.dismiss) private var dismiss
    
    private let encouragementMessages = BotMessages.encouragements

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header with trophy
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue, .cyan)
                            .shadow(color: .blue.opacity(0.3), radius: 10)
                        
                        Text("High Scores")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if scoreManager.personalBest > 0 {
                            Text("Personal Best: \(scoreManager.personalBest)")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Encouragement message
                    Text(encouragementMessages.randomElement() ?? BotMessages.encouragementFallback)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    // Scoreboard
                    VStack(spacing: 0) {
                        if scoreManager.topScores.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                
                                Text("No scores yet!")
                                    .font(.title2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Text("Start practicing to see your scores here")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(40)
                        } else {
                            ForEach(Array(scoreManager.topScores.enumerated()), id: \.element.id) { index, score in
                                HStack {
                                    // Rank
                                    ZStack {
                                        Circle()
                                            .fill(rankColor(for: index))
                                            .frame(width: 30, height: 30)
                                        
                                        Text("\(index + 1)")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    
                                    // Score info
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(score.value) correct")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        
                                        Text(score.formattedDate)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Trophy for top 3
                                    if index < 3 {
                                        Image(systemName: "trophy.fill")
                                            .foregroundColor(rankColor(for: index))
                                            .font(.title3)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func rankColor(for index: Int) -> Color {
        switch index {
        case 0: return .yellow
        case 1: return .gray
        case 2: return .orange
        default: return .blue
        }
    }
}

#Preview {
    let manager = ScoreManager()
    let achievements = AchievementsManager()
    let history = QuestionHistory()
    
    ScoreboardView(scoreManager: manager, achievementsManager: achievements, questionHistory: history)
}
