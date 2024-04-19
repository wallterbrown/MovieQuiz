import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate{
    
    // MARK: - Lifecycle
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var bestScore = 0
    private var totalQuizePlayed = 0
    private var bestScoreDate: Date?
    private var averageAccuracy: Double = 0.0
    private var currentScore = 0
    private var totalCorrectAnswers = 0
    
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Создание объекта QuizStepViewModel с развернутым изображением
        let questionFactory = QuestionFactory()
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        questionFactory.requestNextQuestion()
        
        enum FileManagerError: Error {
            case fileDoesntExist
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    /// приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    /// приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    /// приватный метод, который меняет цвет рамки
    /// принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { // 1
            correctAnswers += 1 // 2
        }
        imageView.layer.masksToBounds = true // 1
        imageView.layer.borderWidth = 8 // 2
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor // 3
        
        /// запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.imageView.layer.borderWidth = 0
            self.imageView.layer.borderWidth = 0 /// Убираем рамку
            self.showNextQuestionOrResults()
        }
        
    }
    
    /// приватный метод для показа результатов раунда квиза
    /// принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showResultsAlert(correctAnswers: Int) {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let averageAccuracy = statisticService.totalAccuracy
        let gamesCount = statisticService.gamesCount
        let bestGameMessage = statisticService.bestGameMessage()
        let bestGame = statisticService.bestGame
        let bestScore = bestGame.correct
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        _ = Date() /// Используем текущую дату
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: "Правильных ответов: \(correctAnswers)/\(questionsAmount)\nКоличество сыгранных квизов: \(gamesCount)\n\(bestGameMessage)\nСредняя точность: \(String(format: "%.2f", averageAccuracy))%",
            buttonText: "Сыграть ещё раз"
        ) {
            self.startNewRound()
        }
        
        AlertPresenter.presentAlert(from: self, with: alertModel)
        statisticService.storeBestGameIfNecessary(correct: correctAnswers, total: questionsAmount)
        
    }
    
    
    private func startNewRound() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory.requestNextQuestion()
    }
    
    private func showNextQuestionOrResults() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            _ = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            showResultsAlert(correctAnswers: correctAnswers)
            totalQuizePlayed += 1
            currentScore = correctAnswers
            totalCorrectAnswers += currentScore
            averageAccuracy = Double(totalCorrectAnswers) / Double(totalQuizePlayed * 10) * 100
            if currentScore > bestScore {
                bestScore = currentScore
                bestScoreDate = Date()
            }
        } else {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
            yesButton.isEnabled = true
            noButton.isEnabled = true
            
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
    
    @IBAction func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true // 2
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
    
}
