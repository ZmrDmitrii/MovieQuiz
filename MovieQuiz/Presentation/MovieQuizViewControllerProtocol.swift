import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(alertModel resultAlert: AlertModel)
    
    func highlightImageBorder(isCorrect: Bool)
    
    func changeStateButton(isEnabled: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showError(alertModel: AlertModel)
}
