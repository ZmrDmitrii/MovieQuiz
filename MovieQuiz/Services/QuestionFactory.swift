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
                    
                    //функционал показа ошибки, если пришел пустой массив или текст ошибки
                    if self.movies.isEmpty || mostPopularMovies.errorMessage != "" {
                        
                        //загрузка удалась, но мы получили пустой массив -> вызываем метод с показом ошибки
                        self.delegate?.didFailToLoadArrayOfMovies(with: mostPopularMovies.errorMessage)
                        
                    } else {
                        
                        //у делегата (vc) вызываем функцию, сообщающую, что загрузка удалась
                        self.delegate?.didLoadDataFromServer()
                        
                    }
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
                imageData = try Data(contentsOf: movie.imageURL)
            } catch {
                //алерт - ошибка загрузки изображения
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.delegate?.didFailToLoadImage(with: error)
                }
                return
            }
            
            //тут рейтинг фильма
            let rating = Float(movie.rating) ?? 0
            
            //тут текст вопроса
            let randomElement = (0...1).randomElement()
            let moreOrLessTitle = randomElement == 0 ? "больше" : "меньше"
            let number = (7...9).randomElement() ?? 7
            let text = "Рейтинг этого фильма\n \(moreOrLessTitle) чем \(number)?"
            let correctAnswer = randomElement == 0 ? rating > Float(number) : rating < Float(number)
            
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
