import Foundation

//изменили тип image с String на Data
struct QuizQuestion {
    let image: Data
    let text: String
    let correctAnswer: Bool
}
