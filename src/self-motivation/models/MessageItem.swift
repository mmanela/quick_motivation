//
//  MessageItem.swift
//  self-motivation
//
//  Created by Matthew Manela on 2/1/25.
//


import Foundation
import Cocoa
 
struct MessageItem: Identifiable, Codable, Hashable, CustomStringConvertible {
    let id: String
    var message: String
    var emoji: String
    
    init(id: String = UUID().uuidString, message: String, emoji: String = "") {
        self.id = id
        self.message = message
        self.emoji = emoji
    }
    
    public var description: String {
        return "\(emoji) \(message)"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
