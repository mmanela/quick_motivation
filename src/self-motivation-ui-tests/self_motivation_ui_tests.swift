//
//  self_motivation_ui_tests.swift
//  self-motivation-ui-tests
//
//  Created by Matthew Manela on 2/1/25.
//

import XCTest

final class self_motivation_ui_tests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor
    func testMenuBarAndPopover() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
        
        // Assert app appears in menu bar
        XCTAssert(app.menuBars.count > 0)
        
        // Mouse app's menu bar icon and assert popover shows
        // Get the menu bar item using its accessibility identifier
        let menuBarItem = app.statusItems["self-motivation"]
        
        // Move mouse to menu bar item coordinates
        let coordinate = menuBarItem.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coordinate.hover()
        
        // Assert popover appears
        let popover = app.windows.element
        XCTAssertTrue(popover.exists, "Popover should appear when hovering over menu bar item")
        
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
