import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    // MARK: - Private Properties
    private let questionAmount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    private var questionFactory: QuestionFactoryProtocol?
    
    // MARK: - Initializers
    init(viewController: MovieQuizViewController? = nil) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        questionFactory?.loadData()
        viewController?.showLoadingIndicator()
    }
    
    // MARK: - Actions
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let alertModel = AlertModel(id: "Network Error",
                                    title: "Ошибка соединения",
                                    message: error.localizedDescription,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            guard let self else { return }
            self.restartGame()
            self.correctAnswers = 0
            viewController?.showLoadingIndicator()
            self.questionFactory?.loadData()
        })
        viewController?.showError(alertModel: alertModel)
    }
    
    func didFailToLoadArrayOfMovies(with errorMessage: String) {
        let alertModel = AlertModel(id: "API Error",
                                    title: "Ошибка загрузки",
                                    message:
                                    """
                                    Произошла ошибка загрузки данных:
                                    \(errorMessage)
                                    Попробуйте еще раз.
                                    """,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            guard let self else { return }
            self.restartGame()
            self.correctAnswers = 0
            viewController?.showLoadingIndicator()
            self.questionFactory?.loadData()
        })
        viewController?.showError(alertModel: alertModel)
    }
    
    func didFailToLoadImage(with error: Error) {
        let alertModel = AlertModel(id: "Image Error",
                                    title: "Ошибка загрузки изображения",
                                    message: error.localizedDescription,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            guard let self else { return }
            viewController?.showLoadingIndicator()
            self.questionFactory?.requestNextQuestion()
        })
        viewController?.showError(alertModel: alertModel)
    }
    
    // MARK: - Private Methods
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let result = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return result
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else { return }
        let isCorrect = currentQuestion.correctAnswer == isYes
        correctAnswers += isCorrect ? 1 : 0
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    private func proceedWithAnswer(isCorrect: Bool){
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        viewController?.changeStateButton(isEnabled: false)
              
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
            self.viewController?.changeStateButton(isEnabled: true)
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            //Result
            //Сохраняю текущий результат игры
            statisticService.store(GameResult(correct: correctAnswers, total: questionAmount, date: Date()))
            
            let alertModel = makeResultAlert()
            viewController?.show(alertModel: alertModel)
        } else {
            //Next Question
            switchToNextQuestion()
            viewController?.showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func makeResultAlert() -> AlertModel {
        let firstLine = correctAnswers == questionAmount ?
            "Поздравляем, результат: \(questionAmount) из \(questionAmount)!\n" :
            "Ваш результат: \(correctAnswers) из \(questionAmount)\n"
        let otherLines =
        """
        Колличество сыграных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """
        
        let resultModel = QuizResultViewModel(id: "Result",
                                              title: "Этот раунд окончен!",
                                              text: firstLine + otherLines,
                                              buttonText: "Сыграть еще раз")
        
        let alertModel = AlertModel(
            id: resultModel.id,
            title: resultModel.title,
            message: resultModel.text,
            buttonText: resultModel.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                self.restartGame()
                self.questionFactory?.requestNextQuestion()
            })
        return alertModel
    }
}
