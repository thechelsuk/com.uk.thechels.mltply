import Combine
import Foundation
import SwiftUI

struct ChatMessagesView: View {
    let messages: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages.indices, id: \.self) { idx in
                        let message = messages[idx]
                        HStack(alignment: .bottom, spacing: 8) {
                            if message.isUser {
                                Spacer()
                                ZStack(alignment: .bottomTrailing) {
                                    Text(message.text)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(Color.blue)
                                        )
                                        .foregroundStyle(.white)
                                        .shadow(
                                            color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1
                                        )
                                        .frame(maxWidth: 260, alignment: .trailing)
                                    if let tapback = message.tapback {
                                        Group {
                                            if tapback == .correct {
                                                Text("🎉")
                                                    .font(.system(size: 24))
                                                    .padding(.top, 4)
                                            } else if tapback == .incorrect {
                                                Text("👎")
                                                    .font(.system(size: 24))
                                                    .padding(.top, 4)
                                            }
                                        }
                                        .offset(x: 0, y: 32)
                                    }
                                }
                            } else {
                                HStack(alignment: .bottom, spacing: 8) {
                                    Image("Robot")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 36, height: 36)
                                        .background(Circle().fill(Color.white))
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1.5)
                                        )
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

                                    if message.isTypingIndicator {
                                        TypingIndicatorView()
                                    } else if isQuizQuestion(message: message) {
                                        Text(message.text)
                                            .accessibilityIdentifier("questionLabel")
                                            .padding(12)
                                            .frame(width: 260, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.green)
                                            )
                                            .foregroundStyle(.white)
                                            .shadow(
                                                color: Color.black.opacity(0.05), radius: 1, x: 0,
                                                y: 1
                                            )
                                    } else {
                                        Text(message.text)
                                            .accessibilityIdentifier(
                                                message.accessibilityIdentifier ?? ""
                                            )
                                            .padding(12)
                                            .frame(width: 260, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(Color.green)
                                            )
                                            .foregroundStyle(.white)
                                            .shadow(
                                                color: Color.black.opacity(0.05), radius: 1, x: 0,
                                                y: 1
                                            )
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 4)
                        .id(message.id)
                    }
                }
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.gray.opacity(0.04))
                )
                .padding(.horizontal, 4)
            }
            .onChange(of: messages) { _, _ in
                // Always scroll to the last message when messages change
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if let last = messages.last {
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .onAppear {
                // Scroll to last message on appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if let last = messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// Helper to detect quiz questions
private func isQuizQuestion(message: ChatMessage) -> Bool {
    guard !message.isUser, !message.isTypingIndicator else { return false }
    // Heuristic: math questions always start with "What is " and end with "?"
    return message.text.hasPrefix("What is ") && message.text.hasSuffix("?")
}

struct TypingIndicatorView: View {
    @State private var animationStep = 0
    let timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .opacity(animationStep == index ? 1.0 : 0.3)
                    .animation(.easeInOut(duration: 0.6), value: animationStep)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.green)
        )
        .frame(width: 260, alignment: .leading)
        .accessibilityIdentifier("typingIndicator")
        .onReceive(timer) { _ in
            animationStep = (animationStep + 1) % 3
        }
    }
}

#Preview {
    let sampleMessages = [
        ChatMessage(text: "Hi! I'm Axl your friendly robot. Let's get ready to play!", isUser: false),
        ChatMessage(text: "Let's start!", isUser: true),
        ChatMessage(text: "What is 5 + 3?", isUser: false),
        ChatMessage(text: "8", isUser: true, tapback: .correct)
    ]

    ChatMessagesView(messages: sampleMessages)
}
