import XCTest
@testable import MovieQuiz

struct StubNetworkClient: NetworkRouting {
    enum TestError: Error {
        case test
    }
    
    //создаем параметр, который будет эмулировать либо ошибку сети, либо успешный ответ
    let emulateError: Bool
    
    //ожидаемый ответ в случае успеха
    private var expectedResponse: Data {
        """
        {
           "errorMessage" : "",
           "items" : [
              {
                 "crew" : "",
                 "fullTitle" : "The Shawshank Redemption (1994)",
                 "id" : "tt0111161",
                 "imDbRating" : "9.3",
                 "imDbRatingCount" : "2915893",
                 "image" : "https://m.media-amazon.com/images/M/MV5BNDE3ODcxYzMtY2YzZC00NmNlLWJiNDMtZDViZWM2MzIxZDYwXkEyXkFqcGdeQXVyNjAwNDUxODI@._V1_.jpg",
                 "rank" : "1",
                 "title" : "The Shawshank Redemption",
                 "year" : "1994"
              },
              {
                 "crew" : "",
                 "fullTitle" : "The Godfather (1972)",
                 "id" : "tt0068646",
                 "imDbRating" : "9.2",
                 "imDbRatingCount" : "2031970",
                 "image" : "https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_.jpg",
                 "rank" : "2",
                 "title" : "The Godfather",
                 "year" : "1972"
              }
            ]
        }
        """.data(using: .utf8) ?? Data()
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        if emulateError {
            handler(.failure(TestError.test))
        } else {
            handler(.success(expectedResponse))
        }
    }
}

class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() throws {
        //Given
        let stubNetworkClient = StubNetworkClient(emulateError: false)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        //When
        //Функция загрузки - асинхронная (т.к handler: @escaping) - испольщуем expectation
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies(handler: { result in
            
            //Then
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case .failure(_):
                XCTFail("Unexpected failure")
            }
            
        })
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        //Given
        let stubNetworkClient = StubNetworkClient(emulateError: true)
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
        //When
        let expectation = expectation(description: "Loading expectation")
        
        loader.loadMovies(handler: { result in
            
            //Then
            switch result {
            case .success(_):
                XCTFail("Unexpected failure")
            case .failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            }
        })
        waitForExpectations(timeout: 1)
    }
}
