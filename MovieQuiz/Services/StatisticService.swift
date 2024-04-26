import Foundation

protocol StatisticService {
    var totalCorrectAnswers: Int { get }
    var totalAmount: Int { get }
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    var totalCorrectAnswers: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.correct.rawValue),
                  let totalCorrectAnswers = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            
            return totalCorrectAnswers
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            
            userDefaults.set(data, forKey: Keys.correct.rawValue)
        }
    }
    var totalAmount: Int {
        
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let totalAmount = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            
            return totalAmount
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalAccuracy.rawValue),
                  let totalAccuracy = try? JSONDecoder().decode(Double.self, from: data) else {
                return 0.0
            }
            return totalAccuracy
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
                  let gamesCount = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }
            
            return gamesCount
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue) else {
                return GameRecord.init(correct: 0, total: 0, date: Date())
            }
            do {
                let record = try JSONDecoder().decode(GameRecord.self, from: data)
                return record
            } catch {
                print("\(String(String(describing: error)))")
                return GameRecord.init(correct: 0, total: 0, date: Date())
            }
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalAccuracy
    }
    
    func store(correct count: Int, total amount: Int) {
        totalCorrectAnswers += count
        totalAmount += amount
        totalAccuracy = min(max((Double(totalCorrectAnswers)/Double(totalAmount)) * 100, 1), 100)
        gamesCount += 1
        if count > bestGame.correct {
            let newBestGame = GameRecord(correct: count, total: amount, date: Date())
            bestGame = newBestGame
        }
    }
    
}
