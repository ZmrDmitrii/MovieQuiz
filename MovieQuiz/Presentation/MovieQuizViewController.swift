import UIKit

final class MovieQuizViewController: UIViewController,
                                     AlertPresenterDelegate {
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLable: UILabel!
    @IBOutlet private weak var counterLable: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var alertPresenter: AlertPresenter?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - AlertPresenterDelegate
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLable.text = step.question
        counterLable.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrect: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.imageView.layer.borderWidth = 0
        }
    }
    
    func show(quiz result: QuizResultViewModel) {
        let alertModel = AlertModel(
            id: result.id,
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                self.presenter.restartGame()
                self.presenter.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.showAlert(model: alertModel)
    }
        
    func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(id: "Network Error",
                                    title: "Ошибка соединения",
                                    message: message,
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
            self.presenter.correctAnswers = 0
            showLoadingIndicator()
            self.presenter.questionFactory?.loadData()
        })
        alertPresenter?.showAlert(model: alertModel)
    }
    
    func showAPIError(errorMessage: String) {
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
            self.presenter.restartGame()
            self.presenter.correctAnswers = 0
            showLoadingIndicator()
            self.presenter.questionFactory?.loadData()
        })
        alertPresenter?.showAlert(model: alertModel)
    }
    
    func showImageLoadError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(id: "Image Error",
                                    title: "Ошибка загрузки изображения",
                                    message: "Неудалось загрузить изображение, попробуйте еще раз",
                                    buttonText: "Попробовать еще раз",
                                    completion: { [weak self] in
            guard let self else { return }
            self.presenter.questionFactory?.requestNextQuestion()
        })
        alertPresenter?.showAlert(model: alertModel)
    }
}
