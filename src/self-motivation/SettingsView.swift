import Foundation
import SwiftUI


struct SettingsView: View {
    @AppStorage(CUSTOM_MESSAGES_KEY) private var customMessages: [MessageItem] = DEFAULT_CUSTOM_MESSAGES
    @AppStorage(MENUBAR_ONLY_EMOJI) private var showOnlyEmojiWhenPinned: Bool = false

    @State private var newMessage: String = ""
    @State private var newEmoji: String = "😊"
    @State private var emojiPickerType: EmojiPickerType? = nil
    
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
        }
        .padding()
        .frame(minWidth: 500, minHeight: 400)
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
}

#Preview {
    SettingsView ()
}
