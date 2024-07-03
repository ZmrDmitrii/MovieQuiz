import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    //этот метод вызовет фабрика, когда вопрос будет готов
    func didReceiveNextQuestion(question: QuizQuestion?)
}
