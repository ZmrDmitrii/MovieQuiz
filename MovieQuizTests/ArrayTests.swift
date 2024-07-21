import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    
    func testGetValueInRange() throws {
        //Given
        let arrayOfNumbers = [1, 2, 3, 4, 5]
        
        //When
        let number = arrayOfNumbers[safe: 2]
        
        //Then
        XCTAssertNotNil(number)
        XCTAssertEqual(number, 3)
    }
    
    func testGetValueOutOfRange() throws {
        //Given
        let arrayOfNumbers = [1, 2, 3, 4, 5]
        
        //When
        let number = arrayOfNumbers[safe: 5]
        
        //Then
        XCTAssertNil(number)
    }
}
