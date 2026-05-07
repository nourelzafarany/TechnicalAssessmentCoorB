//
//  Technical_AssessmentUITests.swift
//  Technical AssessmentUITests
//
//  Created by Nour El Zafarany on 06/05/2026.
//

import XCTest

final class Technical_AssessmentUITests: XCTestCase {
    var app: XCUIApplication!
    
    // MARK: - Lifecycle
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        // Disables animations (optional, but reduces flakiness if you wire it in app)
        app.launchArguments += ["--ui-testing", "-UITestsDisableAnimations"]
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    // MARK: - Launch helper
    private func launch(state: String = "loaded", seed: String = "basic") {
        app.launchEnvironment["UI_STATE"] = state
        app.launchEnvironment["UI_SEED"]  = seed
        app.launch()
    }
    
    // MARK: - Element helpers (robust selectors)
    private func waitForCountriesTitle(timeout: TimeInterval = 5) -> Bool {
        if app.otherElements["countries.title"].waitForExistence(timeout: 1) { return true }
        if app.navigationBars["Countries"].waitForExistence(timeout: 1) { return true }
        return app.staticTexts["Countries"].waitForExistence(timeout: timeout)
    }
    
    private func countriesListElement() -> XCUIElement {
        if app.tables["countries.list"].exists { return app.tables["countries.list"] }
        if app.tables.firstMatch.exists { return app.tables.firstMatch }
        if app.collectionViews["countries.list"].exists { return app.collectionViews["countries.list"] }
        return app.collectionViews.firstMatch
    }

    /// Returns row by ID if present, else by visible country name within the list.
    private func row(alpha2: String, visibleName: String) -> XCUIElement? {
        let idMatch = app.otherElements["countries.row.\(alpha2)"]
        if idMatch.exists { return idMatch }
        
        let list = countriesListElement()
        if list.elementType == .table {
            let cell = list.cells.containing(.staticText, identifier: visibleName).firstMatch
            if cell.exists { return cell }
        }
        
        let text = app.staticTexts[visibleName]
        if text.exists { return text }
        
        return nil
    }
    
    private func plusButton() -> XCUIElement {
        if app.buttons["countries.addButton"].exists { return app.buttons["countries.addButton"] }
        // fallback: the "+" image button
        let add = app.buttons.matching(NSPredicate(format: "label == '+' OR identifier == 'Add Country'")).firstMatch
        return add.exists ? add : app.buttons.element(boundBy: 0)
    }
    
    private func dumpHierarchy() {
        print(app.debugDescription)
        add(XCTAttachment(screenshot: XCUIScreen.main.screenshot()))
    }
    
    func testSearch_FiltersList() {
        launch(state: "loaded", seed: "basic")
        XCTAssertTrue(waitForCountriesTitle())
        // Reveal/tap search field
        if !app.searchFields["Search countries"].exists {
            // On some devices, pull down to reveal the search bar in nav drawer
            app.swipeDown()
        }
        let search = app.searchFields["Search countries"]
        XCTAssertTrue(search.waitForExistence(timeout: 3), "Search field not found")
        
        search.tap()
        search.typeText("egy")
        
        guard let egypt = row(alpha2: "EG", visibleName: "Egypt") else {
            dumpHierarchy()
            XCTFail("Egypt row not found after search")
            return
        }
        XCTAssertTrue(egypt.waitForExistence(timeout: 2))
    }
    
    func testSwipeToDelete_RemovesRow() {
        launch(state: "loaded", seed: "basic")
        XCTAssertTrue(waitForCountriesTitle())
        
        let list = countriesListElement()
        XCTAssertTrue(list.waitForExistence(timeout: 3))
        // Target Egypt cell
        let egyptCell =
        app.otherElements["countries.row.EG"].exists
        ? app.otherElements["countries.row.EG"]
        : (row(alpha2: "EG", visibleName: "Egypt") ?? list.cells.firstMatch)
        XCTAssertTrue(egyptCell.exists, "Egypt row not found for delete")

        // Swipe left and tap Delete
        egyptCell.swipeLeft()
        let delete = app.buttons["Delete"]
        XCTAssertTrue(delete.waitForExistence(timeout: 2), "Delete action not visible")
        delete.tap()
        
        // If using IDs:
        if app.otherElements["countries.row.EG"].exists {
            XCTAssertFalse(app.otherElements["countries.row.EG"].waitForExistence(timeout: 2))
        }
    }
}
