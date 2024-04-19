import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func bestGameMessage() -> String
    func storeBestGameIfNecessary(correct: Int, total: Int)
    
}

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameRecord) -> Bool {
        correct > another.correct
    }
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    var totalAccuracy: Double {
        guard let correct = userDefaults.value(forKey: Keys.correct.rawValue) as? Int,
              let total = userDefaults.value(forKey: Keys.total.rawValue) as? Int,
              total > 0 else {
            return 0
        }
        return Double(correct) / Double(total) * 100
    }
    
    var gamesCount: Int {
        return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
    }
    
    var totalCorrect: Int {
        return userDefaults.integer(forKey: Keys.correct.rawValue)
    }
    
    var totalQuestions: Int {
        return userDefaults.integer(forKey: Keys.total.rawValue)
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        let currentGamesCount = gamesCount
        userDefaults.set(currentGamesCount + 1, forKey: Keys.gamesCount.rawValue)
        
        let currentCorrect = totalCorrect
        let currentTotal = totalQuestions
        
        let newCorrect = currentCorrect + count
        let newTotal = currentTotal + amount
        
        userDefaults.set(newCorrect, forKey: Keys.correct.rawValue)
        userDefaults.set(newTotal, forKey: Keys.total.rawValue)
        
        storeBestGameIfNecessary(correct: count, total: amount)
    }
    
    func bestGameMessage() -> String {
        let bestGame = self.bestGame
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        let date = dateFormatter.string(from: bestGame.date)
        return "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(date))"
    }
    
    func storeBestGameIfNecessary(correct count: Int, total amount: Int) {
        let bestGame = self.bestGame
        let currentAccuracy = Double(bestGame.correct) / Double(bestGame.total)
        let newAccuracy = Double(count) / Double(amount)
        
        if newAccuracy >= currentAccuracy {
            let newRecord = GameRecord(correct: count, total: amount, date: Date())
            self.bestGame = newRecord
        }
    }
}
