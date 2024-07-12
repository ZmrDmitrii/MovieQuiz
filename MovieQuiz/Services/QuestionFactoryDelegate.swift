import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    //этот метод вызовет фабрика, когда вопрос будет готов
    func didReceiveNextQuestion(question: QuizQuestion?)
    
    //метод сообщает об успешной загрузке данных с сервера
    func didLoadDataFromServer()
    
    //метод сообщает, что загрузка неудалась с ошибкой
    func didFailToLoadData(with error: Error)
}
