//
//  Constants.swift
//  self-motivation
//
//  Created by Matthew Manela on 1/19/25.
//

import Foundation

let MAX_MESSAGE_LENGTH = 50

let PINNED_MESSAGE_KEY = "pinnedMessageId"
let CUSTOM_MESSAGES_KEY = "customMessages"
let MENUBAR_ONLY_EMOJI = "onlyRenderEmojiInMenuBar"

let fixedUUID1 = UUID(uuidString: "788453fc-eb50-454c-a7c4-1c6f40e34422")
let fixedUUID2 = UUID(uuidString: "0fbcb346-9192-4cd2-92b2-63c16344c917")
let fixedUUID3 = UUID(uuidString: "a19751e7-299f-4a27-aab0-4107366fd655")
let DEFAULT_PINNED_MESSAGE: MessageItem = MessageItem(id: fixedUUID1!.uuidString, message: "Quick Motivation", emoji: "💡")
let DEFAULT_CUSTOM_MESSAGES: [MessageItem] =  [
    DEFAULT_PINNED_MESSAGE,
    MessageItem(id: fixedUUID2!.uuidString,message: "Exhale", emoji: "😮‍💨"),
    MessageItem(id: fixedUUID3!.uuidString,message: "You got this", emoji: "🚀")
]

