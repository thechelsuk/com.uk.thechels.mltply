//
//  ContentView.swift
//  Mltply
//
//  Created by Mat Benfield on 11/05/2025.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var showingScoreboard = false
    @State private var showingAchievements = false
    // MARK: - View
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if !viewModel.continuousMode {
                    TimerView(
                        timeRemaining: viewModel.timeRemaining, timeString: viewModel.timeString)
                }
                ChatMessagesView(messages: viewModel.messages)
                if viewModel.showMathOperationsCard {
                    ChatCardView(
                        card: ChatCardType(kind: .mathOperations),
                        mathOperations: $viewModel.mathOperations,
                        onSelect: { viewModel.showStartCard = true },
                        addMessage: nil
                    )
                    .padding(.bottom, 8)
                } else if viewModel.showStartCard {
                    ChatCardView(
                        card: ChatCardType(kind: .start),
                        mathOperations: $viewModel.mathOperations,
                        onSelect: { viewModel.startQuiz() },
                        addMessage: nil
                    )
                    .padding(.bottom, 8)
                } else if viewModel.showPlayAgain {
                    Button(action: viewModel.playAgain) {
                        Text("Play Again")
                            .font(.headline)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                    }
                    .accessibilityIdentifier("playAgainButton")
                    .padding(.bottom, 8)
                } else {
                    UserInputView(
                        userInput: $viewModel.userInput,
                        currentQuestion: viewModel.currentQuestion,
                        hasStarted: viewModel.hasStarted,
                        sendMessage: viewModel.sendMessage
                    )
                }
            }
            .navigationTitle("Mltply")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 16) {
                        Button(action: { showingScoreboard = true }) {
                            Image(systemName: "chart.bar")
                        }
                        Button(action: { showingAchievements = true }) {
                            Image(systemName: "trophy")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showSettings) {
                SettingsView(
                    appColorScheme: $viewModel.appColorScheme,
                    mathOperations: $viewModel.mathOperations,
                    continuousMode: $viewModel.continuousMode,
                    timerDuration: $viewModel.timerDuration,
                    soundEnabled: $viewModel.soundEnabled,
                    questionMode: $viewModel.questionMode,
                    practiceSettings: $viewModel.practiceSettings,
                    viewModel: viewModel
                )
            }
            .sheet(isPresented: $showingScoreboard) {
                ScoreboardView(
                    scoreManager: viewModel.scoreManager,
                    achievementsManager: viewModel.achievementsManager,
                    questionHistory: viewModel.questionHistory
                )
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(
                    achievementsManager: viewModel.achievementsManager,
                    questionHistory: viewModel.questionHistory
                )
            }
        }
        .preferredColorScheme(viewModel.appColorScheme.colorScheme)
        .onReceive(viewModel.timer) { _ in
            viewModel.handleTimerTick()
        }
        .onAppear {
            viewModel.resetForWelcome()
        }
        .onChange(of: viewModel.timerDuration) { _, newValue in
            viewModel.handleTimerDurationChange(newValue)
        }
        .onChange(of: viewModel.messages) { _, _ in
            viewModel.handleMessagesChange()
        }
        .onChange(of: viewModel.questionMode) { _, _ in
            viewModel.handleQuestionModeChange()
        }
        .onChange(of: viewModel.practiceSettings.selectedNumbers) { _, _ in
            viewModel.handlePracticeSettingsChange()
        }
    }
}

#Preview {
        ContentView()
    }
