//
//  AppDelegate.swift
//  self-motivation
//
//  Created by Matthew Manela on 2/1/25.
//


import SwiftUI

enum StatusItemVisibility {
    case fullyVisible
    case partiallyVisible
    case hidden
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    @AppStorage(CUSTOM_MESSAGES_KEY) private var customMessages: [MessageItem] = DEFAULT_CUSTOM_MESSAGES
    @AppStorage(PINNED_MESSAGE_KEY) private var pinnedMessageId: String = DEFAULT_CUSTOM_MESSAGES[0].id
    @AppStorage(MENUBAR_ONLY_EMOJI) private var onlyRenderEmojiInMenuBar: Bool = false
    @AppStorage(AUTO_ROTATE_ENABLED_KEY) private var autoRotateEnabled: Bool = false
    @AppStorage(ROTATION_DURATION_KEY) private var rotationDuration: Int = 5
    private var statusItem: NSStatusItem!
    private var observer: NSObjectProtocol!
    var settingsWindow: NSWindow?
    var aboutWindow: NSWindow?
    private var statusItemVisibility: StatusItemVisibility = .fullyVisible
    private var menuItemMouseEventView: MouseEventView =  MouseEventView()
    let defaultIcon: String = "💡"
    var lastVisibility: Bool = true
    var popover: MotivationalPopover?
    let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    private var occlusionEventDebounceTimer: Timer?
    private var lastOnlyRenderEmojiInMenuBar: Bool = false
    private var rotationTimer: Timer?
    private var lastAutoRotateEnabled: Bool = false
    private var lastRotationDuration: Int = 5
    
    static var isTesting: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
    
    override init() {
        super.init()
        if AppDelegate.isTesting {
            return
        }
    }
    
    deinit {
        // Remove observer when the app is deinitialized
        NotificationCenter.default.removeObserver(observer!)
        rotationTimer?.invalidate()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if AppDelegate.isTesting {
            return
        }
        
        setupMenuBarItem()
        setupMenuList()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        
        renderFullPinnedMessage()
        
        popover = MotivationalPopover(viewToAnchorTo: self.statusItem.button!)
        popover?.updatePopoverText(with: String(describing: getPinnedMessage()))
        
        lastAutoRotateEnabled = autoRotateEnabled
        lastRotationDuration = rotationDuration
        setupRotationTimer()
    }
    
    func isStatusItemVisible() -> Bool {
        let itemVisible = self.statusItem.isVisible
        let buttonVisible = self.statusItem.button!.window!.isVisible == true
        let osVisible = self.statusItem.button!.window?.occlusionState.contains(.visible) == true
        debugPrint("isStatusItemVisible: itemVisible: \(itemVisible), buttonVisible: \(buttonVisible), osVisible: \(osVisible)")
        return itemVisible && buttonVisible && osVisible
    }
    
    fileprivate func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.autosaveName = "self-motivation"
        statusItem.behavior = .terminationOnRemoval
        statusItem.button?.setAccessibilityIdentifier("self-motivation")
        
        let button = statusItem.button!
        menuItemMouseEventView.frame = button.bounds
        menuItemMouseEventView.autoresizingMask = [.width, .height]
        menuItemMouseEventView.onMouseEntered = { [weak self] in
            self?.popover?.showPopover()
        }
        menuItemMouseEventView.onMouseExited = { [weak self] in
            if self?.popover?.isPopoverPinned == false{
                self?.popover?.hidePopoverWithDelay()
            }
        }
        menuItemMouseEventView.onMouseDown = { [weak self] in
            if self?.popover?.isPopoverPinned == false{
                self?.popover?.hidePopover()
            }
            self?.statusItem.button?.performClick(nil)
        }
        button.addSubview(menuItemMouseEventView)
        
        observer = NotificationCenter.default.addObserver(forName: NSWindow.didChangeOcclusionStateNotification, object: statusItem.button!.window, queue: nil) { [weak self] _ in
            // Cancel any existing timer
            self?.occlusionEventDebounceTimer?.invalidate()
            
            // Create new timer that will fire after 1 second
            self?.occlusionEventDebounceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
                guard let self = self else { return }
                
                
                // When we get the occlusion event, queue up our reaction after a delay
                // to make sure we are not overreacting to the user switching workspaces
                // since that will cause spurrious occlusion events
                let visible = self.isStatusItemVisible()
                
                if !visible {
                    debugPrint("OcclusionStateNotification: Status item not visible, re-render")
                    self.renderFullPinnedMessage()
                }
                else if self.statusItemVisibility != .fullyVisible {
                    debugPrint("OcclusionStateNotification: Status item is visible, but try to render full-length version")
                    // If we get notified and it is visible,
                    // lets see if we can take more space
                    self.ensureStatusMessageFit()
                }
            }
        }
    }
    
    private func ensureStatusMessageFit() {
        if self.isStatusItemVisible() {
            return
        }
        else if (self.statusItemVisibility == .fullyVisible) {
            let pinnedMessage = self.getPinnedMessage();
            self.statusItemVisibility = .partiallyVisible
            debugPrint("ensureStatusMessageFit: Set size partiallyVisible and render icon only")
            statusItem.button!.title =  pinnedMessage.emoji.isEmpty ? defaultIcon : pinnedMessage.emoji
            
            // Reque this method to check if it is showing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.ensureStatusMessageFit();
            }
        }
        else {
            // If we get here it means even as one icon, it is still not shown.
            // so we force a popover, this may cause mac to make room for us
            self.statusItemVisibility = .hidden
            
            debugPrint("ensureStatusMessageFit: Set size to hidden and try to force with popover")
            popover?.showPopover()
            popover?.hidePopover(forced: true)
        }
        
    }
    
    private func getPinnedMessage() -> MessageItem {
        if pinnedMessageId.isEmpty {
            return DEFAULT_PINNED_MESSAGE
        } else {
            return customMessages.first { $0.id == pinnedMessageId } ?? DEFAULT_PINNED_MESSAGE
        }
    }
    
    func setupMenuList() {
        let menu = NSMenu()
        
        // Dropdown menu items
        var i = 0
        for message in customMessages {
            let item = NSMenuItem(title: String(describing: message), action: #selector(changeMessageHandler(_:)), keyEquivalent: String(i))
            item.representedObject = message
            menu.addItem(item)
            i = i + 1
        }
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: "s"))
        menu.addItem(NSMenuItem(title: "About \(displayName!)",
                                action: #selector(showAbout),
                                keyEquivalent: "a"))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func renderFullPinnedMessage() {
        var didChange = false
        if let button = statusItem?.button {
            let pinnedMessage = self.getPinnedMessage();
            let message = String(describing: pinnedMessage)
            if (button.title != message && button.title != pinnedMessage.emoji)
                || onlyRenderEmojiInMenuBar != lastOnlyRenderEmojiInMenuBar {
                didChange = true
                lastOnlyRenderEmojiInMenuBar = onlyRenderEmojiInMenuBar
                self.statusItemVisibility = .fullyVisible
                if onlyRenderEmojiInMenuBar {
                    button.title = pinnedMessage.emoji
                } else {
                    button.title = message
                }
                popover?.updatePopoverText(with: message)
            }
        }
        
        if didChange {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self = self else { return }
                self.ensureStatusMessageFit();
            }
        }
    }
    
    fileprivate func changeMessage(_ item: MessageItem) {
        pinnedMessageId = item.id
        renderFullPinnedMessage()
        if self.popover?.isPopoverPinned == true {
            popover?.showPopoverWithDelay()
        }
    }
    
    @objc func changeMessageHandler(_ sender: NSMenuItem) {
        if let item = sender.representedObject as? MessageItem {
            changeMessage(item)
        }
    }
    
    // This method is called whenever any value in UserDefaults changes
    @objc func userDefaultsChanged(notification: Notification) {
        renderFullPinnedMessage()
        setupMenuList()
        
        // Only reset rotation timer if rotation settings actually changed
        if autoRotateEnabled != lastAutoRotateEnabled || rotationDuration != lastRotationDuration {
            debugPrint("userDefaultsChanged: Rotation configuration changed autoRotateEnabled:\(lastAutoRotateEnabled) -> \(autoRotateEnabled), rotationDuration: \(lastRotationDuration) -> \(rotationDuration)")
            lastAutoRotateEnabled = autoRotateEnabled
            lastRotationDuration = rotationDuration
            setupRotationTimer()
        }
    }
    
    @objc func showSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.contentViewController = hostingController
            settingsWindow?.title = "Settings"
            settingsWindow?.isReleasedWhenClosed = false
            settingsWindow?.center()
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
    
    @objc func showAbout() {
        if aboutWindow == nil {
            
            let aboutView = AboutView()
            let hostingController = NSHostingController(rootView: aboutView)
            aboutWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            aboutWindow?.contentViewController = hostingController
            aboutWindow?.title = "About \(displayName!)"
            aboutWindow?.isReleasedWhenClosed = false
            aboutWindow?.center()
        }
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
    }
    
    private func setupRotationTimer() {
        rotationTimer?.invalidate()
        rotationTimer = nil
        
        guard autoRotateEnabled && rotationDuration > 0 && !customMessages.isEmpty else {
            return
        }
        
        let timeInterval = TimeInterval(rotationDuration * 60) // Convert minutes to seconds
        
        debugPrint("setupRotationTimer: setting up with rotationDuration: \(rotationDuration) minutes")
        rotationTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] _ in
            if(self != nil) {
                debugPrint("setupRotationTimer: rotation timer invoked after \(self!.rotationDuration) minutes")
            }
            self?.rotateToNextMessage()
        }
    }
    
    private func rotateToNextMessage() {
        guard !customMessages.isEmpty else { return }
        
        let currentIndex = customMessages.firstIndex { $0.id == pinnedMessageId } ?? 0
        let nextIndex = (currentIndex + 1) % customMessages.count
        let nextMessage = customMessages[nextIndex]
     
        changeMessage(nextMessage)
    }
}
