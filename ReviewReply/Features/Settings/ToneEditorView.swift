import SwiftUI
import SwiftData

struct ToneEditorView: View {

    @Query(sort: \ToneConfig.sortOrder)
    private var tones: [ToneConfig]

    @Environment(\.modelContext) private var modelContext
    @State private var showAddTone = false
    @State private var editingTone: ToneConfig?

    var body: some View {
        List {
            Section {
                ForEach(tones) { tone in
                    ToneRow(tone: tone) {
                        editingTone = tone
                    }
                }
                .onMove(perform: reorder)
                .onDelete(perform: deleteTones)
            } header: {
                Text("Drag to reorder · Tap to edit")
            } footer: {
                Text("Each tone tells the AI how to style the response. Edits take effect on the next generation.")
                    .font(.footnote)
                    .foregroundStyle(Color(.secondaryLabel))
            }

            Section {
                Button {
                    showAddTone = true
                } label: {
                    Label("Add Tone", systemImage: "plus.circle.fill")
                        .foregroundStyle(Theme.Colors.primary)
                }
            }
        }
        .navigationTitle("Response Tones")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            EditButton()
        }
        .sheet(isPresented: $showAddTone) {
            ToneFormView(tone: nil) { name, instruction, emoji in
                addTone(name: name, instruction: instruction, emoji: emoji)
            }
        }
        .sheet(item: $editingTone) { tone in
            ToneFormView(tone: tone) { name, instruction, emoji in
                tone.name        = name
                tone.instruction = instruction
                tone.emoji       = emoji
                try? modelContext.save()
            }
        }
    }

    // MARK: - Actions

    private func addTone(name: String, instruction: String, emoji: String) {
        let maxOrder = tones.map(\.sortOrder).max() ?? -1
        let tone = ToneConfig(name: name, instruction: instruction, emoji: emoji, sortOrder: maxOrder + 1)
        modelContext.insert(tone)
        try? modelContext.save()
    }

    private func reorder(from source: IndexSet, to destination: Int) {
        var reordered = tones
        reordered.move(fromOffsets: source, toOffset: destination)
        for (i, tone) in reordered.enumerated() {
            tone.sortOrder = i
        }
        try? modelContext.save()
    }

    private func deleteTones(at offsets: IndexSet) {
        for i in offsets { modelContext.delete(tones[i]) }
        try? modelContext.save()
    }
}

// MARK: - Tone Row

private struct ToneRow: View {
    let tone: ToneConfig
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Tappable label area opens edit sheet
            Button(action: onEdit) {
                HStack(spacing: 12) {
                    Text(tone.emoji).font(.title2)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(tone.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(.label))
                        Text(tone.instruction)
                            .font(.caption)
                            .foregroundStyle(Color(.secondaryLabel))
                            .lineLimit(2)
                    }
                }
            }
            .buttonStyle(.plain)
            Spacer()
            Toggle("", isOn: Binding(get: { tone.isEnabled }, set: { tone.isEnabled = $0 }))
                .labelsHidden()
        }
    }
}

// MARK: - Tone Form Sheet

struct ToneFormView: View {

    let tone: ToneConfig?
    let onSave: (String, String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String        = ""
    @State private var instruction: String = ""
    @State private var emoji: String       = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Emoji") {
                    TextField("e.g. 🎯", text: $emoji)
                }
                Section("Tone Name") {
                    TextField("e.g. Empathetic", text: $name)
                }
                Section {
                    ZStack(alignment: .topLeading) {
                        if instruction.isEmpty {
                            Text("Describe how the AI should write this response…")
                                .foregroundStyle(Color(.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $instruction)
                            .frame(minHeight: 100)
                    }
                } header: {
                    Text("AI Instruction")
                } footer: {
                    Text("This sentence tells the model how to write the response. Be specific.")
                }
            }
            .navigationTitle(tone == nil ? "New Tone" : "Edit Tone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(name, instruction, emoji)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.isEmpty || instruction.isEmpty || emoji.isEmpty)
                }
            }
        }
        .onAppear {
            if let t = tone {
                name        = t.name
                instruction = t.instruction
                emoji       = t.emoji
            }
        }
    }
}
