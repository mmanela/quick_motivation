import Foundation
import SwiftUI


struct SettingsView: View {
    @AppStorage(CUSTOM_MESSAGES_KEY) private var customMessages: [MessageItem] = DEFAULT_CUSTOM_MESSAGES
    @AppStorage(MENUBAR_ONLY_EMOJI) private var showOnlyEmojiWhenPinned: Bool = false
    @AppStorage(AUTO_ROTATE_ENABLED_KEY) private var autoRotateEnabled: Bool = false
    @AppStorage(ROTATION_DURATION_KEY) private var rotationDuration: Int = 5

    @State private var newMessage: String = ""
    @State private var newEmoji: String = "😊"
    @State private var emojiPickerType: EmojiPickerType? = nil
    @State private var selectedDuration: RotationDuration = .fiveMinutes
    @State private var customMinutes: String = "1"
    
    let MAX_MINUTES = 9999
    
    private var isCustomMinutesValid: Bool {
        guard selectedDuration == .custom else { return true }
        guard !customMinutes.isEmpty else { return false }
        guard let minutes = Int(customMinutes) else { return false }
        return minutes > 0 && minutes <= MAX_MINUTES
    }
    
    private var minuteText: String {
        guard let minutes = Int(customMinutes) else { return "minutes" }
        return minutes == 1 ? "minute" : "minutes"
    }
    
    enum EmojiPickerType: Identifiable {
        case new
        case editing(MessageItem)
        
        var id: String {
            switch self {
            case .new: return "new"
            case .editing(let item): return item.id
            }
        }
    }
    
    enum RotationDuration: String, CaseIterable, Identifiable {
        case fiveMinutes = "5 minutes"
        case fifteenMinutes = "15 minutes"
        case thirtyMinutes = "30 minutes"
        case oneHour = "1 hour"
        case custom = "Custom"
        
        var id: String { rawValue }
        
        var minutes: Int {
            switch self {
            case .fiveMinutes: return 5
            case .fifteenMinutes: return 15
            case .thirtyMinutes: return 30
            case .oneHour: return 60
            case .custom: return 0
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Motivational Messages")
                .font(.title.bold())
                .padding(.zero)
            
            Text("Note: Only the emoji may show if there isn't enough space for the full message")
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            List {
                ForEach(customMessages) { item in
                    HStack {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.gray)
                        
                        Text(item.emoji)
                        
                        Text(item.message)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Spacer()
                        
                        Button(action: { deleteMessage(item) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                        
                    }.font(.system(size: 15))
                        .buttonStyle(BorderlessButtonStyle())
                }
                .onMove(perform: moveMessage)
            }
            .listStyle(PlainListStyle())
            
            HStack {
                Button(newEmoji) {
                    emojiPickerType = .new
                }
                .font(.system(size: 25))
                .popover(item: $emojiPickerType) { pickerType in
                    EmojiPicker(selectedEmoji: $newEmoji) {
                        emojiPickerType = nil
                    }
                    .frame(minWidth: 325, minHeight: 375)
                }
                
                TextField("New Message", text: $newMessage)
                    .font(.system(size: 20))
                    .padding(.all, 2)
                    .onChange(of: newMessage) { oldValue, newValue in
                        if newValue.count > MAX_MESSAGE_LENGTH {
                            newMessage = String(newValue.prefix(MAX_MESSAGE_LENGTH))
                        }
                    }
                    .onSubmit {addNewMessage()}
                
                Button(action: addNewMessage) {
                    Text("Add")
                }
                .font(.system(size: 20))
                .buttonStyle(.borderedProminent)
                .disabled(newMessage.isEmpty)
            }
            .padding(.horizontal)
             
            HStack {
                VStack { Divider() }.padding(.vertical, 10)
                Text("Options")
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .padding(.horizontal, 8)
                VStack { Divider() }.padding(.vertical, 10)
            }
            .padding(.horizontal)

            
            HStack {
                Toggle("Show only the emoji in the menu bar (full message shows in popover)", isOn: $showOnlyEmojiWhenPinned)
                Spacer()
            }
            .padding(.horizontal)
            
            HStack(spacing: 2) {
                Toggle("Automatically rotate messages", isOn: $autoRotateEnabled)
                
                if autoRotateEnabled {
                    Text("every")
                        .padding(.leading, 2)
                    
                    Picker("", selection: $selectedDuration) {
                        ForEach(RotationDuration.allCases) { duration in
                            Text(duration.rawValue).tag(duration)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                    .padding(.leading, -5)
                    
                    if selectedDuration == .custom {
                        HStack(spacing: 4) {
                            TextField("Minutes", text: $customMinutes)
                                .frame(width: 80)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(isCustomMinutesValid ? Color.clear : Color.red, lineWidth: 2)
                                )
                                .onChange(of: customMinutes) { oldValue, newValue in
                                    // Only allow numbers
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered != newValue {
                                        customMinutes = filtered
                                        return
                                    }
                                    
                                    // Limit to MAX_MINUTES
                                    if let minutes = Int(filtered), minutes > MAX_MINUTES {
                                        customMinutes = String(MAX_MINUTES)
                                    }
                                    else {
                                        customMinutes = filtered
                                    }
                                }
                            
                            Text(minuteText)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: 25)
        }
        .padding()
        .frame(minWidth: 525, minHeight: 400)
        .onAppear {
            updateSelectedDurationFromStorage()
        }
        .onChange(of: selectedDuration) { oldValue, newValue in
            updateRotationDurationFromSelection()
        }
        .onChange(of: customMinutes) { oldValue, newValue in
            if selectedDuration == .custom && isCustomMinutesValid {
                if let minutes = Int(newValue) {
                    rotationDuration = minutes
                }
            }
        }
    }
    
    private func addNewMessage() {
        guard !newMessage.isEmpty else { return }
        let newItem = MessageItem(message: newMessage, emoji: newEmoji)
        customMessages.append(newItem)
        newMessage = ""
    }
    
    private func deleteMessage(_ item: MessageItem) {
        customMessages.removeAll { $0.id == item.id }
    }
    
    private func moveMessage(from source: IndexSet, to destination: Int) {
        customMessages.move(fromOffsets: source, toOffset: destination)
    }
    
    private func updateSelectedDurationFromStorage() {
        switch rotationDuration {
        case 5: selectedDuration = .fiveMinutes
        case 15: selectedDuration = .fifteenMinutes
        case 30: selectedDuration = .thirtyMinutes
        case 60: selectedDuration = .oneHour
        default:
            selectedDuration = .custom
            customMinutes = rotationDuration > 0 ? String(rotationDuration) : "1"
        }
    }
    
    private func updateRotationDurationFromSelection() {
        if selectedDuration != .custom {
            rotationDuration = selectedDuration.minutes
        } else if customMinutes.isEmpty {
            customMinutes = "1"
        }
    }
}

#Preview {
    SettingsView ()
}
