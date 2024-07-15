import Foundation

protocol QuestionFactoryProtocol {
    func requestNextQuestion()
    
    //инициирует загрузку данных с сервера
    func loadData()
}
