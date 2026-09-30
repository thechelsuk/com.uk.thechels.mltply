import SwiftUI

struct NumberSelectionView: View {
    @Binding var practiceSettings: PracticeSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Difficulty Level") {
                ForEach(NumberDifficulty.allCases) { level in
                    DifficultyCard(
                        level: level,
                        isSelected: practiceSettings.difficulty == level,
                        onSelect: {
                            practiceSettings.difficulty = level
                        }
                    )
                }
            }
            
            if practiceSettings.difficulty.allowsGranularSelection {
                Section("Select Numbers for Practice") {
                    ForEach(1...12, id: \.self) { number in
                        HStack {
                            Text(verbatim: "\(number)")
                                .font(.headline)
                            Spacer()
                            Toggle(isOn: Binding(
                                get: { practiceSettings.selectedNumbers.contains(number) },
                                set: { isSelected in
                                    if isSelected {
                                        practiceSettings.selectedNumbers.insert(number)
                                    } else {
                                        practiceSettings.selectedNumbers.remove(number)
                                    }
                                }
                            )) { EmptyView() }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if practiceSettings.selectedNumbers.contains(number) {
                                practiceSettings.selectedNumbers.remove(number)
                            } else {
                                practiceSettings.selectedNumbers.insert(number)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Select All") {
                        practiceSettings.selectedNumbers = Set(1...12)
                    }
                    
                    Button("Clear All") {
                        practiceSettings.selectedNumbers.removeAll()
                    }
                    .foregroundStyle(.red)
                }
            } else {
                Section {
                    Text("Numbers will be randomly generated from 1 to \(practiceSettings.difficulty.range.upperBound.formatted()).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Number Range")
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

struct DifficultyCard: View {
    let level: NumberDifficulty
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: level.iconName)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .accentColor)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(level.displayName)
                        .font(.headline)
                        .foregroundStyle(isSelected ? .white : .primary)
                    
                    Text(level.rangeDescription)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.accentColor : Color.clear)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
}

#Preview {
    NumberSelectionView(practiceSettings: .constant(PracticeSettings()))
}
