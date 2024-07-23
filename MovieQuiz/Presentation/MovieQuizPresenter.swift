import UIKit

final class MovieQuizPresenter {
    
    let questionAmount = 10
    private var currentQuestionIndex = 0
    
    var correctAnswers = 0
    var statisticService: StatisticServiceProtocol = StatisticService()
    var questionFactory: QuestionFactoryProtocol?
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let result = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return result
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            //Result
            //Сохраняю текущий результат игры
            statisticService.store(GameResult(correct: correctAnswers, total: self.questionAmount, date: Date()))
            
            //Создаю модель результата QuizResultViewModel
            let resultModel = QuizResultViewModel(id: "Result",
                                                  title: "Этот раунд окончен!",
                                                  text: (correctAnswers == self.questionAmount ?
                                                         "Поздравляем, результат: \(self.questionAmount) из \(self.questionAmount)!\n" :
                                                            "Ваш результат: \(correctAnswers) из \(self.questionAmount)\n") +
                                                  """
                                                  Колличество сыграных квизов: \(statisticService.gamesCount)
                                                  Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                                                  Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                                  """,
                                                  buttonText: "Сыграть еще раз")
            //Передаю созданную модель в функцию show
            viewController?.show(quiz: resultModel)
        } else {
            //Next Question
            self.switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == isYes)
    }
    
    
    
}
