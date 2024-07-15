import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    //этот метод вызовет фабрика, когда вопрос будет готов
    func didReceiveNextQuestion(question: QuizQuestion?)
    
    //метод сообщает об успешной загрузке данных с сервера
    func didLoadDataFromServer()
    
    //метод сообщает, что загрузка неудалась с ошибкой
    func didFailToLoadData(with error: Error)
    
    //метод сообщает, что пришел пустой массив фильмов => ошибка загрузки
    func didLoadEmptyArrayOfMovies(with errorMessage: String)
    
    //метод сообщает, что не получилось загрузить изображение
    func didFailToLoadImage(with error: Error)
}
