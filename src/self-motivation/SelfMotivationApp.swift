//
//  self_motivationApp.swift
//  self-motivation
//
//  Created by Matthew Manela on 1/19/25.
//

import SwiftUI
import SwiftData

@main
struct SelfMotivationApp: App { 
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        NSApplication.shared.setActivationPolicy(.accessory) // No dock icon
    }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
