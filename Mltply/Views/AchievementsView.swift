import SwiftUI

struct AchievementsView: View {
    @ObservedObject var achievementsManager: AchievementsManager
    @ObservedObject var questionHistory: QuestionHistory
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFilter: AchievementFilter = .all
    
    enum AchievementFilter: String, CaseIterable {
        case all = "All"
        case unlocked = "Unlocked"
        case locked = "Locked"
    }
    
    var filteredAchievements: [Achievement] {
        switch selectedFilter {
        case .all:
            return achievementsManager.achievements
        case .unlocked:
            return achievementsManager.unlockedAchievements
        case .locked:
            return achievementsManager.lockedAchievements
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.yellow, .orange)
                            .shadow(color: .orange.opacity(0.3), radius: 10)
                        
                        Text("Achievements")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("\(achievementsManager.unlockedAchievements.count) of \(achievementsManager.achievements.count) unlocked")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Filter
                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(AchievementFilter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Streak Achievements
                    if !achievementsManager.streakAchievements.filter({ filterMatches($0) }).isEmpty {
                        achievementSection(
                            title: "Streak Master",
                            icon: "flame.fill",
                            achievements: achievementsManager.streakAchievements.filter { filterMatches($0) }
                        )
                    }
                    
                    // Total Achievements
                    if !achievementsManager.totalAchievements.filter({ filterMatches($0) }).isEmpty {
                        achievementSection(
                            title: "Practice Milestones",
                            icon: "star.fill",
                            achievements: achievementsManager.totalAchievements.filter { filterMatches($0) }
                        )
                    }
                    
                    // Number Mastery
                    if !achievementsManager.masteryAchievements.filter({ filterMatches($0) }).isEmpty {
                        achievementSection(
                            title: "Number Mastery",
                            icon: "checkmark.seal.fill",
                            achievements: achievementsManager.masteryAchievements.filter { filterMatches($0) }
                        )
                    }
                    
                    // Stats footer
                    VStack(spacing: 8) {
                        Text("Keep practicing to unlock more achievements!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if questionHistory.longestStreak > 0 {
                            Text("Best Streak: \(questionHistory.longestStreak) • Total Correct: \(questionHistory.totalCorrect)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func filterMatches(_ achievement: Achievement) -> Bool {
        switch selectedFilter {
        case .all:
            return true
        case .unlocked:
            return achievement.isUnlocked
        case .locked:
            return !achievement.isUnlocked
        }
    }
    
    private func achievementSection(title: String, icon: String, achievements: [Achievement]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                Text(title)
                    .font(.headline)
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 80), spacing: 16)
            ], spacing: 16) {
                ForEach(achievements) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.pastelColor : Color.gray.opacity(0.2))
                    .frame(width: 70, height: 70)
                    .shadow(color: achievement.isUnlocked ? achievement.pastelColor.opacity(0.3) : .clear, radius: 8)
                
                switch achievement.icon {
                case .emoji(let emoji):
                    Text(emoji)
                        .font(.system(size: 32))
                case .symbol(let name, _):
                    Image(systemName: name)
                        .font(.system(size: 28))
                        .foregroundStyle(achievement.isUnlocked ? .white : .gray)
                }

                if !achievement.isUnlocked {
                    Circle()
                        .fill(.black.opacity(0.5))
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                }
            }
            
            Text(achievement.title)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 32)
                .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
            
            if achievement.isUnlocked, let date = achievement.unlockedDate {
                Text(date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 80)
    }
}

#Preview {
    let history = QuestionHistory()
    let manager = AchievementsManager()
    
    AchievementsView(achievementsManager: manager, questionHistory: history)
}
