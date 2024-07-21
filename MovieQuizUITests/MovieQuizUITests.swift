import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        //try???
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        app = XCUIApplication()
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        //try???
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
        app = nil
        
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testYesButton() {
        //находим первоначальный постер
        //приостанавливаем тест, чтобы постеры точно загрузились (sleep - нежелательно в реал. пр-х)
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        //находим кнопку Да и нажимаем на нее
        app.buttons["Yes"].tap()
        sleep(3)
        
        //еще раз находим постер
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        //проверяем, что постеры существуют и они разные
        XCTAssertFalse(firstPosterData == secondPosterData)
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertFalse(firstPosterData == secondPosterData)
    }
    
    func testIndexChange() {
        sleep(3)
        let firstIndex = app.staticTexts["Index"]
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondIndex = app.staticTexts["Index"]
        
        XCTAssertFalse(firstIndex == secondIndex)
        XCTAssertTrue(secondIndex.label == "2/10")
    }
    
    func testAlertGameResult() {
        for _ in 1...10 {
            sleep(3)
            app.buttons["Yes"].tap()
        }
        
        sleep(3)
        let alert = app.alerts["Result"]
        let title = app.staticTexts["Этот раунд окончен!"]
        let button = app.buttons["Сыграть еще раз"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(title.label == "Этот раунд окончен!")
        XCTAssertTrue(button.label == "Сыграть еще раз")
    }
    
    func testPlayAgain() {
        for _ in 1...10 {
            sleep(3)
            app.buttons["Yes"].tap()
        }
        
        sleep(3)
        let alert = app.alerts["Result"]
        
        alert.buttons["Сыграть еще раз"].tap()
        sleep(3)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
        
    }
}
