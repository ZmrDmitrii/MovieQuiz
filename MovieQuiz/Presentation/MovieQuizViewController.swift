import UIKit

final class MovieQuizViewController: UIViewController,
                                     QuestionFactoryDelegate,
                                     AlertPresenterDelegate {
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLable: UILabel!
    @IBOutlet private weak var counterLable: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionAmount = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self, moviesLoader: MoviesLoader())
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == true)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion else { return }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == false)
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.hideLoadingIndicator()
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadEmptyArrayOfMovies(with errorMessage: String) {
        showAPIError(errorMessage: errorMessage)
    }
    
    func didFailToLoadImage(with error: Error) {
        showImageLoadError(message: error.localizedDescription)
    }
    
    // MARK: - AlertPresenterDelegate
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    //изменили image UIImage(data: ...) вместо UIImage(named: ...)
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let result = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return result
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLable.text = step.question
        counterLable.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        correctAnswers += isCorrect ? 1 : 0
        
        changeStateButton(isEnabled: false)
        
        // Разобраться: выполнение кода через заданный промежуток времени.
        // Запускаем задачу через 1 секунду c помощью диспетчера задач.
        // используем weak ссылку на self; разворачиваем опционал self
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
           // Код, вызываемый через 1 секунду
            guard let self else { return }
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
            self.changeStateButton(isEnabled: true)
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount - 1 {
            //Result
            //Сохраняю текущий результат игры
            statisticService.store(GameResult(correct: correctAnswers, total: questionAmount, date: Date()))
            
            //Создаю модель результата QuizResultViewModel
            let resultModel = QuizResultViewModel(id: "Result",
                                                  title: "Этот раунд окончен!",
                                                  text: (correctAnswers == questionAmount ?
                                                  "Поздравляем, результат: \(questionAmount) из \(questionAmount)!\n" :
                                                  "Ваш результат: \(correctAnswers) из \(questionAmount)\n") + 
                                                  """
                                                  Колличество сыграных квизов: \(statisticService.gamesCount)
                                                  Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
                                                  Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                                                  """,
                                                  buttonText: "Сыграть еще раз")
            //Передаю созданную модель в функцию show
            show(quiz: resultModel)
        } else {
            //Next Question
            currentQuestionIndex += 1
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }
    
    //Теперь функция show отвечает за создание AlertModel из QuizResultViewModel и передачу этой модели в AlertPresenter
    private func show(quiz result: QuizResultViewModel) {
        let alertModel = AlertModel(
            id: result.id,
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                self.correctAnswers = 0
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.showAlert(model: alertModel)
    }
        
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(id: "Network Error",
                                    title: "Ошибка соединения",
                                    message: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            showLoadingIndicator()
            self.questionFactory?.loadData()
        })
        alertPresenter?.showAlert(model: alertModel)
    }
    
    private func showAPIError(errorMessage: String) {
        hideLoadingIndicator()
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
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            showLoadingIndicator()
            self.questionFactory?.loadData()
        })
        alertPresenter?.showAlert(model: alertModel)
    }
    
    private func showImageLoadError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(id: "Image Error",
                                    title: "Ошибка загрузки изображения",
                                    message: "Неудалось загрузить изображение, попробуйте еще раз",
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            guard let self else { return }
            self.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.showAlert(model: alertModel)
    }
}
