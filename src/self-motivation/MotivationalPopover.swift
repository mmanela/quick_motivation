//
//  MotivationalPopover.swift
//  self-motivation
//
//  Created by Matthew Manela on 2/2/25.
//
import SwiftUI

class MotivationalPopover {
    private var popoverMouseEventView: MouseEventView =  MouseEventView()
    private var popoverController: CustomPopoverViewController!
    var isPopoverPinned: Bool = false
    private var hidePopoverTimer: Timer?
    private var showPopoverTimer: Timer?
    let popoverHidingDelay: TimeInterval = 0.5
    let popoverShowDelay: TimeInterval = 1.0 
    private var popover: PopoverWindow = PopoverWindow()
    private let anchorView: NSView
    
    init(viewToAnchorTo: NSView) {
        self.anchorView = viewToAnchorTo
        setupPopover()
    }
    
    private func setupPopover() {
        popover = PopoverWindow()
        popoverController = CustomPopoverViewController()
        popoverController.onPinStateChanged = { isPinned in
            if isPinned {
                self.isPopoverPinned = true
            } else {
                self.isPopoverPinned = false
            }
        }
        popover.contentViewController = popoverController
        
        let view = popover.contentViewController?.view
        if view != nil {
            popoverMouseEventView.frame = view!.bounds
            popoverMouseEventView.autoresizingMask = [.width, .height]
            popoverMouseEventView.onMouseEntered = { [weak self] in
                self?.cancelHidePopoverTimer()
            }
            popoverMouseEventView.onMouseExited = { [weak self] in
                if self?.isPopoverPinned == false{
                    self?.hidePopoverWithDelay()
                }
            }
            view!.addSubview(popoverMouseEventView)
        }
    }
    
    public func updatePopoverText(with message: String) {
        self.popoverController.updateMessage(message)
    }
    
    private func renderPopover() {
        // Convert anchor view's frame to screen coordinates
        let anchorRect = anchorView.window?.convertToScreen(
            anchorView.convert(anchorView.bounds, to: nil)
        )
        
        guard let anchorScreenRect = anchorRect else { return }
        
        // Calculate the new position
        let windowRect = popover.frame
        
        // Center horizontally below anchor view
        let x = anchorScreenRect.midX - (windowRect.width / 2)
        
        // Position vertically right below anchor view
        let y = anchorScreenRect.minY
        
        popover.setFrameTopLeftPoint(NSPoint(x: x, y: y))
        popover.makeKeyAndOrderFront(nil)
    }
    
    public func showPopover() {
        cancelHidePopoverTimer()
        if !popover.isVisible {
            renderPopover()
        }
    }
    
    public func hidePopover(forced: Bool = false) {
        if popover.isVisible && (forced || !isPopoverPinned){
            popover.close()
        }
        // Clear any existing timer when directly hiding
        cancelHidePopoverTimer()
    }
    
    public func hidePopoverWithDelay() {
        // Cancel any existing timer first
        cancelHidePopoverTimer()
        
        // Create new timer
        hidePopoverTimer = Timer.scheduledTimer(withTimeInterval: popoverHidingDelay, repeats: false) { [weak self] _ in
            self?.hidePopover()
        }
    }
    
    public func showPopoverWithDelay() {
        // Cancel any existing timer first
        cancelShowPopoverTimer()
        
        // Create new timer
        showPopoverTimer = Timer.scheduledTimer(withTimeInterval: popoverShowDelay, repeats: false) { [weak self] _ in
            self?.showPopover()
        }
    }
    
    private func cancelHidePopoverTimer() {
        hidePopoverTimer?.invalidate()
        hidePopoverTimer = nil
    }
    
    private func cancelShowPopoverTimer() {
        showPopoverTimer?.invalidate()
        showPopoverTimer = nil
    }
    
}

class PopoverWindow: NSWindow {
    
    init() {
        super.init(
            contentRect: .zero,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        self.level = .floating
        self.collectionBehavior = [.fullScreenAuxiliary,
                                   .canJoinAllSpaces,
                                   .canJoinAllApplications,
                                   .stationary,
                                   .ignoresCycle]
        self.isMovableByWindowBackground = false
        self.isOpaque = false
        self.hasShadow = false
        self.isReleasedWhenClosed = false
        self.backgroundColor = .clear
        self.level = .floating
        self.backingType = .buffered
        self.styleMask = [.borderless, .nonactivatingPanel]
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
