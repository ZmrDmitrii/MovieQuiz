//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by Дмитрий Замараев on 23/7/24.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var highlightImageBorderCalled = false
    var changeStateButtonCalled = false
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
        
    }
    
    func show(alertModel resultAlert: MovieQuiz.AlertModel) {

    }
    
    func highlightImageBorder(isCorrect: Bool) {
        highlightImageBorderCalled = true
    }
    
    func changeStateButton(isEnabled: Bool) {
        changeStateButtonCalled = true
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showError(alertModel: MovieQuiz.AlertModel) {
        
    }
}

final class QuestionFactoryMock: QuestionFactoryProtocol {
    func requestNextQuestion() {
        
    }
    
    func loadData() {
        
    }
    
    
}

final class MovieQuizPresenterTests: XCTestCase {
    
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
    func testYesButtonClicked() {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        presenter.currentQuestion = question
        
        presenter.yesButtonClicked()
        
        XCTAssertTrue(viewControllerMock.highlightImageBorderCalled)
        XCTAssertTrue(viewControllerMock.highlightImageBorderCalled)
    }
}
