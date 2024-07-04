import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetter(than bestGameResult: GameResult) -> Bool {
        correct > bestGameResult.correct
    }
}
