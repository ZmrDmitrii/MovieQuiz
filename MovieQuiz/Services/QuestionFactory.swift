import Foundation

final class QuestionFactory {
    // MARK: - Private Properties
    private weak var delegate: QuestionFactoryDelegate?
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    // MARK: - Initializers
    init(delegate: QuestionFactoryDelegate, moviesLoader: MoviesLoading) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
}

extension QuestionFactory: QuestionFactoryProtocol {
    //инициирует загрузку данных с сервера
    func loadData() {
        moviesLoader.loadMovies(handler: { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    
                    // movies - массив фильмов
                    self.movies = mostPopularMovies.items
                    
                    //у делегата (vc) вызываем функцию, сообщающую, что загрузка удалась
                    self.delegate?.didLoadDataFromServer()
                    
                case .failure(let error):
                    
                    //у делегата (vc) вызываем функцию, сообщающую, что загрузка провалилась и передадим ей ошибку для показа
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        })
    }
    
    //передает вопрос делегату QuestionFactoryDelegate (vc) в функцию didReceiveNextQuestion(question:)
    func requestNextQuestion() {
        
        // работа с сетью и изображениями должна быть не только в асинхронных функциях, но и в отдельном потоке
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            // индекс - рандомное число от 0 до последнего индекса филма (250?)
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            // безопасно (если элемента с таким индексом нет в массиве - не страшно) достаем фильм с рандомным индексом из массива фильмов
            guard let movie = self.movies[safe: index] else { return }
            
            //тут будет дата изображения фильма
            var imageData = Data()
            
            do {
                //не стал менять на resizedImageUrl, по моему мнению качество изображения без изменения URL выше
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                print("Failed to load image")
            }
            
            //тут рейтинг фильма
            let rating = Float(movie.rating) ?? 0
            
            //тут текст вопроса
            let number = (8...9).randomElement() ?? 9
            let text = "Рейтинг этого фильма\nбольше чем \(number)?"
            let correctAnswer = rating > Float(number)
            
            //создаем вопрос с формате QuizQuestion
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            //отправляем созданный вопрос во vc для показа
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}

/*
private let questions: [QuizQuestion] = [
    QuizQuestion(
        image: "The Godfather",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "The Dark Knight",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "Kill Bill",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "The Avengers",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "Deadpool",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "The Green Knight",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: true),
    QuizQuestion(
        image: "Old",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: false),
    QuizQuestion(
        image: "The Ice Age Adventures of Buck Wild",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: false),
    QuizQuestion(
        image: "Tesla",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: false),
    QuizQuestion(
        image: "Vivarium",
        text: "Рейтинг этого фильма\n больше чем 6?",
        correctAnswer: false)
    ]
 */
