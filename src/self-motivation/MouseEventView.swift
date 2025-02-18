//
//  MouseEventView.swift
//  self-motivation
//
//  Created by Matthew Manela on 2/1/25.
//


import SwiftUI
import SwiftData

class MouseEventView: NSView {
    var onMouseEntered: (() -> Void)?
    var onMouseExited: (() -> Void)?
    var onMouseDown: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTracking()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTracking()
    }
    
    private func setupTracking() {
        let trackingArea = NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect, .enabledDuringMouseDrag],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        onMouseEntered?()
    }
    
    override func mouseExited(with event: NSEvent) {
        onMouseExited?()
    }
    
    override func mouseDown(with event: NSEvent) {
        onMouseDown?()
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        // Return nil to indicate this view should not handle the event
       // onMouseDown?()
        if onMouseDown != nil {
            return self
        }
        return nil
    }
    
    override var acceptsFirstResponder: Bool {
        return false
    }

    override var mouseDownCanMoveWindow: Bool {
        return true
    }
}
