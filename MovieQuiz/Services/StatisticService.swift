import Foundation

protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }

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
    

    
    func store(correct count: Int, total amount: Int) {
        let currentAccuracy = totalAccuracy
        let newAccuracy = Double(count) / Double(amount)
        
        if newAccuracy > currentAccuracy {
            userDefaults.set(count, forKey: Keys.correct.rawValue)
            userDefaults.set(amount, forKey: Keys.total.rawValue)
            userDefaults.set(Date(), forKey: Keys.bestGame.rawValue)
            storeBestGameIfNecessary(correct: count, total: amount)
        }
        
        let currentGamesCount = gamesCount
        userDefaults.set(currentGamesCount + 1, forKey: Keys.gamesCount.rawValue)
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
    
    func bestGameMessage() -> String {
           let bestGame = self.bestGame
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
           let date = dateFormatter.string(from: bestGame.date)
           return "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(date))"
       }
    
    func storeBestGameIfNecessary(correct count: Int, total amount: Int) {
        let currentAccuracy = totalAccuracy
        let newAccuracy = Double(count) / Double(amount) * 100
        print("New accuracy: \(newAccuracy), Current accuracy: \(currentAccuracy)")

        if newAccuracy >= currentAccuracy {
            let bestGame = GameRecord(correct: count, total: amount, date: Date())
            self.bestGame = bestGame
            print("Best game updated: \(bestGame)")
            // Проверяем, успешно ли сохранен лучший результат
                  let savedBestGame = self.bestGame
                  if savedBestGame.correct == bestGame.correct && savedBestGame.total == bestGame.total && savedBestGame.date == bestGame.date {
                      print("Best game successfully saved to UserDefaults")
                  } else {
                      print("Failed to save best game to UserDefaults")
                  }
        }

        // Обновляем total и correct независимо от текущей точности
        userDefaults.set(count, forKey: Keys.correct.rawValue)
        userDefaults.set(amount, forKey: Keys.total.rawValue)
    }

}
