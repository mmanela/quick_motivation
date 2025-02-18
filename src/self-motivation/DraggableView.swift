//
//  DraggableView.swift
//  self-motivation
//
//  Created by Matthew Manela on 2/3/25.
//


import SwiftUI
import SwiftData

class DraggableView: NSView {
    var initialLocation: NSPoint?
    
    override func mouseDown(with event: NSEvent) {
        initialLocation = event.locationInWindow
    }
    
    override func mouseDragged(with event: NSEvent) {
        guard let initialLocation = initialLocation else { return }
        let currentLocation = event.locationInWindow
        let dx = currentLocation.x - initialLocation.x
        let dy = currentLocation.y - initialLocation.y
        
        if let window = self.window {
            var newOrigin = window.frame.origin
            newOrigin.x += dx
            newOrigin.y += dy
            window.setFrameOrigin(newOrigin)
        }
    }
}
