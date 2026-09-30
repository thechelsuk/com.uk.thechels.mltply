// BotMessages.swift
// Centralized configuration for all bot text messages in Mltply

import Foundation

struct BotMessages {
    static let welcome = "Hi! I'm Buddy your friendly robot. I love maths and I'm keen to learn about the numbers you have on planet Earth, so let's get ready to play! 🌍"
    static let onboardingSettings =
        "Before you start, check out the settings to adjust them to your liking. You can find them in the top right corner and you can choose some numbers, operations, and a timer to make the game more fun!"
    static let onboardingReply = "Once ready, reply with any message to begin!"
    static let playAgain = "Would you like to play again?"
    static let readyToBegin = "Ready to begin?"
    static let chooseTimer = "First, choose your timer:"
    static let letsGo = "OK, great, Let's go!"
    static let newRound = "Starting a new round!"
    
    static func achievementUnlocked(_ achievement: Achievement) -> String {
        "\(achievement.icon.chatEmoji) Achievement unlocked: \(achievement.title)\n\(achievement.unlockedMessage)"
    }
}
