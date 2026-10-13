// Demo.swift
// Screenshot mode, for tools/screenshots.sh. Debug builds only.
//
// `-demo` plays a short round by itself, answering through the quiz's real logic (one answer wrong), so the chat,
// scores and achievements fill in just as they would for a child. `-screen settings|scoreboard|achievements` then
// opens that sheet, and `-timed` plays against the two-minute timer instead of in continuous mode. The capture script
// installs the app fresh each run, so nothing played here outlives the screenshots.

#if DEBUG
import Foundation

enum Demo {
    static var isOn: Bool { arguments.contains("-demo") }
    static var screen: String? { value(after: "-screen") }
    static var timed: Bool { arguments.contains("-timed") }

    private static var arguments: [String] { ProcessInfo.processInfo.arguments }

    private static func value(after flag: String) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else { return nil }
        return arguments[index + 1]
    }

    /// Past rounds for the scoreboard, best first.
    private static let pastScores = [24, 19, 17, 12, 9, 6]

    /// Plays the opening messages, a reply, then `answers` answers (the one at `wrongAt` wrong), and calls `done` once
    /// Buddy has asked the next question, with its answer typed in the reply field.
    static func play(_ viewModel: QuizViewModel, answers: Int = 8, wrongAt: Int = 2, done: @escaping () -> Void) {
        viewModel.messageDelayScale = 0.02
        viewModel.continuousMode = !timed
        viewModel.timerDuration = 2
        viewModel.timeRemaining = 120
        viewModel.mathOperations = MathOperationSettings()
        viewModel.practiceSettings = PracticeSettings()
        let now = Date()
        viewModel.scoreManager.allScores = pastScores.enumerated().map { day, value in
            Score(value: value, date: now.addingTimeInterval(Double(-(day + 1) * 86_400)))
        }
        viewModel.resetForWelcome()

        var answered = 0
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
            guard viewModel.isMessageQueueIdle else { return }
            if !viewModel.hasStarted {
                viewModel.userInput = "Ready!"
                viewModel.sendMessage()
            } else if answered < answers, let question = viewModel.currentQuestion {
                viewModel.userInput = String(question.answer + (answered == wrongAt ? 1 : 0))
                viewModel.sendMessage()
                answered += 1
            } else {
                timer.invalidate()
                viewModel.messageDelayScale = 1
                // the next answer half-typed, and the chat scrolled down to the question it answers
                if let question = viewModel.currentQuestion { viewModel.userInput = String(question.answer) }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { viewModel.scrollToLastMessage() }
                done()
            }
        }
    }
}
#endif
