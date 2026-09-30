import Foundation
import SwiftUI

// BotMessages is in the same target, so no import needed, but ensure file is included in target membership in Xcode.

struct ChatCardType: Identifiable, Equatable {
    enum CardKind: Equatable {
        case mathOperations
        case start
    }
    let id = UUID()
    let kind: CardKind
}

struct ChatCardView: View {
    let card: ChatCardType
    @Binding var mathOperations: MathOperationSettings
    let onSelect: () -> Void

    @State private var showMathOperationsResult: Bool = false
    @State private var showStartResult: Bool = false

    // Add a closure to allow adding messages from the card
    var addMessage: ((String) -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // Bot avatar
            Image("robot")
                .resizable()
                .frame(width: 28, height: 28)
                .background(Circle().fill(Color.white))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            // Card bubble
            VStack(alignment: .leading, spacing: 8) {
                contentView
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color.gray.opacity(0.15)))
            .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var contentView: some View {
        switch card.kind {
        case .mathOperations:
            mathOperationsView
        case .start:
            startView
        }
    }

    private var mathOperationsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose your math operations:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 2)

            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    Toggle("Addition", isOn: $mathOperations.additionEnabled)
                    Toggle("Subtraction", isOn: $mathOperations.subtractionEnabled)
                }
                HStack(spacing: 12) {
                    Toggle("Multiplication", isOn: $mathOperations.multiplicationEnabled)
                    Toggle("Division", isOn: $mathOperations.divisionEnabled)
                }
                HStack(spacing: 12) {
                    Toggle("Squares", isOn: $mathOperations.squareEnabled)
                    Toggle("√ Roots", isOn: $mathOperations.squareRootEnabled)
                }
            }

            Button(action: {
                showMathOperationsResult = true
                onSelect()
                // Show operations set as a user message
                if let addMessage = addMessage {
                    let enabledOperations = mathOperations.summary
                    addMessage("Math operations set: \(enabledOperations)")
                }
            }) {
                Text("Set Operations")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(mathOperations.hasAtLeastOneEnabled ? Color.blue : Color.gray)
                    .foregroundStyle(.white)
                    .cornerRadius(16)
            }
            .disabled(!mathOperations.hasAtLeastOneEnabled)

            if showMathOperationsResult {
                Text("Operations set: \(mathOperations.summary)")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                    .padding(.top, 4)
            }
        }
    }

    private var startView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(BotMessages.readyToBegin)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 2)
            Button(action: {
                showStartResult = true
                onSelect()
            }) {
                Text("Start Quiz")
                    .font(.headline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 32)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .cornerRadius(16)
            }
            if showStartResult {
                Text("Let's go!")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ChatCardView(
            card: ChatCardType(kind: .mathOperations),
            mathOperations: .constant(MathOperationSettings()),
            onSelect: {},
            addMessage: nil
        )
        
        ChatCardView(
            card: ChatCardType(kind: .start),
            mathOperations: .constant(MathOperationSettings()),
            onSelect: {},
            addMessage: nil
        )
    }
    .padding()
}
