import Foundation

//Создали структуру для передачи данных алерта в AlertPresenter
struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
}
