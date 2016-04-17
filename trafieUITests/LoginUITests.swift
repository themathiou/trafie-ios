//
//  trafieUITests.swift
//  trafieUITests
//
//  Created by mathiou on 09/12/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import Foundation
import XCTest

class LoginUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /*
    * Testing all login pages are in place.
    * Login. Register. Reset Password.
    */
    func testAllLoginPages() {
    }

    /*
    * Testing basic login flow.
    */
    func testBasicLoginFlow() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.textFields["Email"].tap()
        app.textFields["Email"]
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"]
        
        let moreNumbersKey = app.keys["more, numbers"]
        moreNumbersKey.tap()
        moreNumbersKey.tap()
        app.secureTextFields["Password"]
        app.buttons["Done"].tap()
        app.buttons["Login"].tap()
        
    }
    
    /*
    * Testing Register flow.
    */
    func testRegisterFlow() {
    }
    
    /*
    * Testing Reset Password flow.
    */
    func testResetPasswordFlow() {
    }
}
