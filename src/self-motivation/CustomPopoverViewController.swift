//
//  CustomPopoverViewController.swift
//  self-motivation
//
//  Created by Matthew Manela on 2/1/25.
//


import SwiftUI
import SwiftData




class CustomPopoverViewController: NSViewController {
    private var messageLabel: NSTextField! = NSTextField(labelWithString: "")
    private var pinButton: NSButton!
    
    // Callback closure for pin state changes
    var onPinStateChanged: ((Bool) -> Void)?
    override func loadView() {
        // Create the base view with zero frame - it will size to fit
        view = DraggableView(frame: .zero)
        
        // Enable layer and set visual properties
        view.wantsLayer = true
        if #available(macOS 10.14, *) {
            view.layer?.backgroundColor = NSColor(named: NSColor.Name("windowBackgroundColor"))?.cgColor
            ?? NSColor.windowBackgroundColor.cgColor
        } else {
            view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        }
        
        // Keep the popover styling
        view.layer?.cornerRadius = 8.0
        view.layer?.borderWidth = 1.0
        view.layer?.borderColor = NSColor.separatorColor.cgColor
        
        // Add shadow for depth
        view.layer?.shadowColor = NSColor.black.cgColor
        view.layer?.shadowOpacity = 0.2
        view.layer?.shadowOffset = NSSize(width: 0, height: -3)
        view.layer?.shadowRadius = 3.0
      
        
        // Configure the label with fixed font size
        messageLabel.font = .systemFont(ofSize: 24, weight: .medium)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.alignment = .center
        messageLabel.backgroundColor = .clear
        messageLabel.isBezeled = false
        messageLabel.isEditable = false
        messageLabel.textColor = .labelColor
        
        // Create and configure the pin button
        pinButton = NSButton(frame: .zero)
        pinButton.font = .systemFont(ofSize: 12, weight: .medium)
        pinButton.translatesAutoresizingMaskIntoConstraints = false
        pinButton.isBordered = false
        pinButton.setButtonType(.toggle)
        pinButton.image = NSImage(systemSymbolName: "pin", accessibilityDescription: "Pin")
        pinButton.alternateImage = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: "Unpin")
        pinButton.imagePosition = .imageOnly
        pinButton.target = self
        pinButton.action = #selector(pinButtonClicked)
        pinButton.toolTip = "Pin"
        
        view.addSubview(messageLabel)
        view.addSubview(pinButton)
        
        // Set constraints with padding
        NSLayoutConstraint.activate([
            // Pin button constraints
            // Pin button now anchored to the top right
            pinButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            pinButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            pinButton.widthAnchor.constraint(equalToConstant: 12),
            pinButton.heightAnchor.constraint(equalToConstant: 12),
            
            messageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            messageLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func updateMessage(_ message: String) {
        messageLabel.stringValue = message
        // Calculate the size needed for the text
        let attributedString = NSAttributedString(string: message, attributes: [.font: messageLabel.font!])
        let textSize = attributedString.size()
        
        // Add padding to the calculated size
        let totalWidth = textSize.width + 40  // 20pts padding on each side
        let totalHeight = textSize.height + 40 // 20pts padding on each side
        
        view.window?.setContentSize(.zero)
        view.frame.size = .zero
        view.setFrameSize(NSSize(width: totalWidth, height: totalHeight))
        //        // Update the popover's content size
        //        if let popover = view.window?.value(forKey: "popover")  as? NSPopover {
        //            popover.contentSize = .zero
        //            popover.contentSize = NSSize(width: totalWidth, height: totalHeight)
        //        }
        
        view.layoutSubtreeIfNeeded()
    }
    
    @objc private func pinButtonClicked() {
        if pinButton.state == .on {
            pinButton.toolTip = "Unpin"
        } else {
            pinButton.toolTip = "Pin"
        }
        // Call the callback with the current state of the button
        onPinStateChanged?(pinButton.state == .on)
    }
}
