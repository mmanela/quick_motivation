//
//  EmojiPicker.swift
//  self-motivation
//
//  Created by Matthew Manela on 2/1/25.
//


import Foundation
import SwiftUI

struct EmojiPicker: View {
    @Binding var selectedEmoji: String
    let dismiss: () -> Void
    let emojis = ["☀️", "⭐️", "🌟","✨", "🚀", "💪", "🏆",  "🌈", "🔥", "🌺", "🦋",
                  "🍀", "🧗‍♂️", "🌞", "💥", "🌌", "🛤️", "🏅", "⛰️", "🔒",
                  "🧠", "❤️",  "💜",  "💡", "⌛️",  "✅", "🎉", "💎", "🐶",
                  "😮‍💨", "🙂",  "🤗", "🥰", "‼️", "❗️", "🌊", "🍵", "🎧", "🧘‍♀️",]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 0) {
            ForEach(emojis, id: \.self) { emoji in
                Button(emoji) {
                    selectedEmoji = emoji
                    dismiss()
                }
                .buttonStyle(CustomHoverButtonStyle())
                
            }
        }
        .padding()
    }
}

struct CustomHoverButtonStyle: ButtonStyle {
    @State private var isHovering = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 30))
            .background(.clear)
            .padding(.all, 5)
            .background(isHovering ? Color.gray.opacity(0.2) : Color.clear)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}
