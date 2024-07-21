import UIKit

//Создал класс, который отвечает за отображение алерта
//AlertPresenter принимает AlertModel и делегата(VC), который реализует метод presentAlert для отображения алерта
//Вызывает функцию presentAlert у делегата
final class AlertPresenter {
    private weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    func showAlert(model: AlertModel) {
        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        
        //При создании алерта - добавляем ему Accessibility Identifier
        alert.view.accessibilityIdentifier = model.id
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion?()
        }
        
        alert.addAction(action)
        delegate?.presentAlert(alert)
    }
}
