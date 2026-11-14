//
//  SpyPassUITests.swift
//  SpyPassUITests
//
//  Created by david on 11/14/26.
//

import XCTest

final class SpyPassUITests: XCTestCase {

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
    func testTutorialCanCompleteSkipAndReopen() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--show-tutorial"]
        app.launch()

        XCTAssertTrue(app.otherElements["tutorial-screen"].waitForExistence(timeout: 3))

        let next = app.buttons["tutorial-next"]
        XCTAssertTrue(next.exists)
        next.tap()
        next.tap()
        next.tap()
        XCTAssertEqual(next.label, "Start playing")
        next.tap()

        let howToPlay = app.buttons["how-to-play"]
        XCTAssertTrue(howToPlay.waitForExistence(timeout: 3))
        howToPlay.tap()
        XCTAssertTrue(app.otherElements["tutorial-screen"].waitForExistence(timeout: 3))
        app.buttons["tutorial-skip"].tap()
        XCTAssertTrue(howToPlay.waitForExistence(timeout: 3))
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            let app = XCUIApplication()
            app.launchArguments = ["--skip-tutorial"]
            app.launch()
        }
    }
}
